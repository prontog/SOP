Simple Order Protocol (sop). An imaginary protocol.
========

This is a simple, text protocol for an imaginary stock exchange. I created it for my [blog](https://prontog.wordpress.com/).

All message types follow the format HEADER|PAYLOAD|TRAILER (note that '|' is not included in the protocol).

The HEADER is very simple:

Field | Length | Type | Description
-----|---------|------|------
SOH | 1 | STRING | Start of header.
LEN | 3 | NUMERIC |Length of the payload (i.e. no header/trailer).

The TRAILER is even simpler:

Field | Length | Type | Description
-----|---------|------|------
ETX | 1 | STRING | End of text.

The message types are:

Type | Description | Payload Spec
-----|-------------|-----------
NO | New Order | [NO.csv](specs/NO.csv)
OC | Order Confirmation | [OC.csv](specs/OC.csv)
TR | Trade | [TR.csv](specs/TR.csv)
RJ | Rejection | [RJ.csv](specs/RJ.csv)
EN | Exchange News | [EN.csv](specs/EN.csv)
BO | Best Bid and Offer | [BO.csv](specs/BO.csv)
LO | Lough Out Loud (experimental) | [LO.csv](specs/LO.csv)

The [specs](specs) dir contains the specification for each message type in CSV format.
