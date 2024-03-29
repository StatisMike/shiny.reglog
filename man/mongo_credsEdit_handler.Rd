% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mongo_connector.R
\name{mongo_credsEdit_handler}
\alias{mongo_credsEdit_handler}
\title{MongoDB edit to the database handler}
\usage{
mongo_credsEdit_handler(self, private, message)
}
\arguments{
\item{self}{R6 object element}

\item{private}{R6 object element}

\item{message}{RegLogConnectorMessage which need to contain within its data:
\itemize{
\item account_id
\item password
}

It can also contain elements for change:
\itemize{
\item new_username
\item new_email
\item new_password
}}
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}

Default handler function querying database to confirm credentials
edit procedure and update values saved within database. Used within object of
\code{RegLogMongoConnector} class internally.
}
\seealso{
Other MongoDB handler functions: 
\code{\link{mongo_login_handler}()},
\code{\link{mongo_register_handler}()},
\code{\link{mongo_resetPass_confirmation_handler}()},
\code{\link{mongo_resetPass_generation_handler}()}
}
\concept{MongoDB handler functions}
\concept{mongo_handler}
\keyword{internal}
