### LOADERS ###################################################################
#' Loads a spec.file.
#'
#' @param spec.file the file containing the msg specification.
#' @return a dataframe with the specification.
read.spec <- function(spec.file) {
    read.csv(file.path(SOP_SPECS_PATH, spec.file), stringsAsFactors = FALSE)
}

#' Add the timestamp and filename specs on an existing SOP spec.
#' The timestamp format is YYYY-mm-dd HH:MM:SS.SSS
#'
#' @param spec a SOP spec data.frame
add.sop.common.specs <- function(spec) {
    rbind(sopsrv_log.specs, spec)
}

#' Adds multi.fwf columns to a SOP spec
#'
prepare.sop.spec.for.multi.fwf <- function(spec) {
    spec$widths <- spec$Length
    spec$col.names <- spec$Field
    spec
}

#' Convert from string to POSIXlt.
#'
#' @param s date as string.
#' @return date as POSIXlt.
#' @export
convertDates <- function(s) {
    if (!is.null(s)) {
        s$timestamp <- sub(':(...)$','.\\1', s$timestamp)
        s$timestamp <- strptime(s$timestamp, format = '%Y-%m-%d %H:%M:%OS')
        # If platform is 32bit add half a millisecond to timestamp field. This is a known
        # issue. For more info, see http://stackoverflow.com/a/10932215/850119
        if (grepl("32-bit", sessionInfo()$platform)) {
            s$timestamp <- s$timestamp + 0.0005
        }
    }
    s
}

#' Reads a SOP log into a list of data.frames.
#'
#' @param log.file the SOP log file.
#' @return a list of dataframes for each message type.
#' @export
read.sop.log <- function(log.file) {
    select <- function(line, allspecs) {
        s <- substr(line, sop.msgtype.offset + 1, sop.msgtype.offset + sop.msgtype.length)
        s
    }

    # Make a list of specs per msg type
    specs <- lapply(sop.types, FUN = function(i) read.spec(paste(i, '.csv', sep = "")) )
    names(specs) <- sop.types

    # Insert the time stamp spec. We expect each line to have the filename and timestamp
    # followed by the message.
    specs <- lapply(specs, FUN = add.sop.common.specs)
    specs <- lapply(specs, FUN = prepare.sop.spec.for.multi.fwf)

    out <- multifwf::read.multi.fwf(log.file,
                                    specs,
                                    select = select,
                                    stringsAsFactors = FALSE,
                                    comment.char = '')

    lapply(out, FUN = convertDates)
}

### LATENCY ###################################################################

#' Move common columns to the front
#'
#' Move common columns to the front of the latency data.frame.
#'
#' @param lat.data a dataframe produced by getLatency.
#' @param commonFields a vector with the names of the common columns
#' @return Return a dataframe with the common columns moved to the front.
moveCommonColumns <- function(lat.data, commonFields) {
    allFields <- names(lat.data)
    # Keep only the common field that are actually common. There might be a case where some field
    # might be missing in an old dataset.
    intersectFields <- intersect(commonFields, allFields)
    if ( !setequal(commonFields, intersectFields) ) {
        warning(paste('Missing field(s):', toString(setdiff(commonFields, allFields))))
        commonFields <- intersectFields
    }

    # Find the uncommon fields and remove the NUL dummy field.
    uncommonFields <- setdiff(allFields, commonFields)
    if ('NUL' %in% names(uncommonFields)) {
        uncommonFields['NUL'] <- NULL
    }

    # Reorder the fields.
    lat.data[, union(commonFields, uncommonFields)]
}

#' Creates the description string x -> y
get_desc <- function(name.x, name.y) {
    rx <- '^.*\\$'
    paste(sub(rx, '', name.x), '->', sub(rx, '', name.y))
}

#' Removes duplicate rows and keeps the one with the smallest timestamp.
removeDuplicates <- function(d, by) {
    d <- d[order(d$timestamp),]
    d[!duplicated(d[, by]), ]
}

#' Calculate latency between two merged dataframes and return the rows over a specified threshold
#'
#' Merge two dataframes containing by common columns and calculate latencies by subtracting timestamp.x from timestamp.y. Finally return the subset with leatency over a specified threshold. The latency is rounded to milliseconds.
#'
#' @param x the first dataframe.
#' @param y the second dataframe.
#' @param threshold the threshold in milliseconds. Defaults to 50.
#' @param by specifications of the columns used for merging.
#' @param desc some description for the relation between x and y. Defaults to "x -> y".
#' @param dedup keep the minimum latency when more than one pairs match. Defaults to TRUE.
#' @return Return the merged dataframe
#' @seealso \code{\link{merge}}
#' @export
getLatency <- function(x, y,
                       threshold = 50,
                       by = c('client_ip_port', 'clientId'),
                       desc = get_desc(deparse(substitute(x)),deparse(substitute(y))),
                       dedup = TRUE) {
    suppressMessages(library('plyr'))

    # Parameter validations.
    if (is.null(x)) {
        warning(paste(deparse(substitute(x)), 'is empty'))
        return()
    }
    if (is.null(y)) {
        warning(paste(deparse(substitute(y)), 'is empty'))
        return()
    }
    intersectBy <- intersect(by, names(x))
    if ( !setequal(by, intersectBy) ) {
        stop(paste('by: missing column(s) from', deparse(substitute(x)), ':', toString(setdiff(by, intersectBy))))
    }
    intersectBy <- intersect(by, names(y))
    if ( !setequal(by, intersectBy) ) {
        stop(paste('by: missing column(s) from', deparse(substitute(y)), ':', toString(setdiff(by, intersectBy))))
    }


    if (length(unique(x[, by])) == length(y[, by])) {
        if (dedup) {
            y <- removeDuplicates(y, by)
        }

        x_y <- merge(x, y, by = by, all.x = F)
        x_y$latency <- round(as.numeric(x_y$timestamp.y - x_y$timestamp.x) * 1000)

        if (threshold > 0) {
            x_y <- subset(x_y, x_y$latency > threshold)
        }

        commonFields <- c('latency', by, 'timestamp.x', 'msgtype.x', 'timestamp.y', 'msgtype.y')
        moveCommonColumns(x_y[order(x_y$timestamp.x),], commonFields)
    }
    else {
        stop(paste(desc, 'by', by,
                   'contains duplicate values. Skipping calculations.'),
             call. = FALSE)
    }
}

#' Return the slowest latency data
#'
#' Return the slowest latency data
#'
#' @param lat.data a data.frame returned from getLatency.
#' @param limit the max number of records to return.
#' @return Return a dataframe with the records with highest latency.
#' @export
getSlowest <- function(lat.data, limit = 100) {
    if (!is.null(lat.data)) {
        ordered_at <- lat.data[order(lat.data$latency, decreasing = T),]
        head(ordered_at, limit)
    }
}


SOP_SPECS_PATH <- Sys.getenv("SOP_SPECS_PATH")
sop.log <- Sys.getenv("SOP_LOG")
# The SOP message types that are specified in the specs dir.
sop.types <- sub(".csv$", "", dir(SOP_SPECS_PATH, pattern = "^[[:alnum:]]{2}.csv$"))
sopsrv_log.specs <- read.spec("sopsrv_log.csv")
sop.msgtype.offset <- sum(sopsrv_log.specs$Length)
sop.msgtype.length <- 2

op <- options(warn = -1)
out <- read.sop.log(sop.log);

counts <- as.matrix(sapply(out, function(el) {
    el_cnt <- nrow(el)
    if (is.null(el_cnt))
        el_cnt <- 0
    el_cnt
}))
colnames(counts) <- c('# of msgs')
print(counts)

threshold = 0
NO_OC <- getLatency(out$NO, out$OC, threshold)
NO_RJ <- getLatency(out$NO, out$RJ, threshold)
options(op)

# This enables milliseconds when writing the dataframe to CSV
options(digits.secs = 3)

# Save to CSV
if (!is.null(NO_OC)) {
    write.csv(NO_OC, "NO_OC.csv", row.names = FALSE)
}
if (!is.null(NO_RJ)) {
    write.csv(NO_RJ, "NO_RJ.csv", row.names = FALSE)
}

# Clean up unecessary variables before saving the R environment. Only out
# should be saved because is takes a lot of time to calculate.
rm(threshold, NO_OC, NO_RJ)
