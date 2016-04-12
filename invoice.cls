%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Copyright (c) 2011 Trey Hunner                                          %
%                                                                          %
%  Permission is hereby granted, free of charge, to any person obtaining   %
%  a copy of this software and associated documentation files (the         %
%  "Software"), to deal in the Software without restriction, including     %
%  without limitation the rights to use, copy, modify, merge, publish,     %
%  distribute, sublicense, and/or sell copies of the Software, and to      %
%  permit persons to whom the Software is furnished to do so, subject to   %
%  the following conditions:                                               %
%                                                                          %
%  The above copyright notice and this permission notice shall be          %
%  included in all copies or substantial portions of the Software.         %
%                                                                          %
%  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,         %
%  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF      %
%  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                   %
%  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE  %
%  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION  %
%  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION   %
%  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.         %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\ProvidesClass{invoice}

\LoadClass[12pt]{article}

\usepackage[letterpaper,hmargin=0.79in,top=0.79in,bottom=1.5in]{geometry}
\usepackage[parfill]{parskip} % Do not indent paragraphs
\usepackage{fp} % Fixed-point arithmetic
\usepackage{calc} % Counters for totaling hours and cost
\usepackage{longtable}
\usepackage[utf8]{inputenc}
\usepackage{fancyhdr}
\usepackage{advdate}
\usepackage{varwidth}

\newcommand{\due}[1][14]{%
    \begingroup
    \AdvanceDate[#1]%
    \today%
    \endgroup
}%

\def \tab {\hspace*{3ex}} % Define \tab to create some horizontal white space

\newcommand\companyname[1]{\newcommand\@companyname{#1}}
\newcommand\cvr[1]{\newcommand\@cvr{#1}}
\newcommand\address[1]{\newcommand\@address{#1}}
\newcommand\contact[1]{\newcommand\@contact{#1}}
\newcommand\bank[1]{\newcommand\@bank{#1}}

\newcommand\cname[1]{\newcommand\@cname{#1}}
\newcommand\caddress[1]{\newcommand\@caddress{#1}}
\newcommand\ccity[1]{\newcommand\@ccity{#1}}
\newcommand\czip[1]{\newcommand\@czip{#1}}
\newcommand\cremark[1]{\newcommand\@cremark{#1}}
\newcommand\invoiceno[1]{\newcommand\@invoiceno{#1}}

%\pagestyle{empty} % No page numbers
\pagestyle{fancy}
\renewcommand{\headrulewidth}{0pt} %remove top line
\fancyhf{}
\lfoot{
    \begin{varwidth}[t]{10cm}
        \raggedright
        {\bf ADDRESS}\\
        \@address
    \end{varwidth}    
}
\cfoot{
    \begin{varwidth}[t]{10cm}
        \raggedright
        {\bf CONTACT}\\
        \@contact
    \end{varwidth}    
}
\rfoot{
    \begin{varwidth}[t]{10cm}
        \raggedright
        {\bf BANK}\\
        \@bank \\
        {\bf CVR}\\
        \@cvr
    \end{varwidth}    
}

\linespread{1.5} % Line spacing

\setlength{\doublerulesep}{\arrayrulewidth} % Double rules look like one thick one

% Command for setting a default hourly rate
\newcommand{\feetype}[1]{
    \textbf{#1}
    \\
}

% Counters for totaling up hours and dollars
\newcounter{hours} \newcounter{subhours} \newcounter{cost} \newcounter{subcost} \newcounter{moms} \newcounter{topay}
\setcounter{hours}{0} \setcounter{subhours}{0} \setcounter{cost}{0} \setcounter{subcost}{0} \setcounter{moms}{0} \setcounter{topay}{0}

% Formats inputed number with 2 digits after the decimal place
\newcommand*{\formatNumber}[1]{\FPround{\cost}{#1}{2}\cost} %

% Returns the total of counter
\newcommand*{\total}[1]{\FPdiv{\t}{\arabic{#1}}{1000}\formatNumber{\t}}

\newcommand*{\header}{%
    \hfil{\Huge\bf \@companyname}\hfil % Company providing the invoice
    \bigskip\break % Whitespace
    \hrule % Horizontal line
    \vspace{2em}
    {\bf \@cname} \hfill \today \\
    \@caddress \hfill {\bf Invoice \#\@invoiceno} \\
    \@czip~\@ccity \hfill Due: \due\\\\
    \@cremark\\
}

% Create an invoice table
\newenvironment{invoiceTable}{

    % Create a new row from title, unit quantity, unit rate, and unit name
    \newcommand*{\unitrow}[4]{%
         \addtocounter{cost}{1000 * \real{##2} * \real{##3}}%
         \addtocounter{subcost}{1000 * \real{##2} * \real{##3}}%
         \addtocounter{moms}{250 * \real{##2} * \real{##3}}%
         \addtocounter{topay}{1250 * \real{##2} * \real{##3}}%
         ##1 & \formatNumber{##2} ##4 & \formatNumber{##3} DKK & \FPmul{\cost}{##2}{##3}\formatNumber{\cost} DKK%
         \\
    }
    % Create a new row from title and expense amount
    \newcommand*{\feerow}[2]{%
         \addtocounter{cost}{1000 * \real{##2}}%
         \addtocounter{subcost}{1000 * \real{##2}}%
         \addtocounter{moms}{250 * \real{##2}}%
         \addtocounter{topay}{1250 * \real{##2}}%
         ##1 & & \formatNumber{##2} DKK & \FPmul{\cost}{##2}{1}\formatNumber{\cost} DKK%
         \\
    }

    \newcommand{\subtotalNoStar}{
        {\bf Subtotal} & {\bf \total{subhours} hours} &  & {\bf \total{subcost} DKK}
        \setcounter{subcost}{0}
        \setcounter{subhours}{0}
        \\*[1.5ex]
    }
    \newcommand{\subtotalStar}{
        {\bf Subtotal} & & & {\bf \total{subcost} DKK}
        \setcounter{subcost}{0}
        \\*[1.5ex]
    }
    \newcommand{\subtotal}{
         \hline
         \@ifstar
         \subtotalStar%
         \subtotalNoStar%
    }

    % Create a new row from date and hours worked (use stored fee type and hourly rate)
    \newcommand*{\hourrow}[3]{%
        \addtocounter{hours}{1000 * \real{##2}}%
        \addtocounter{subhours}{1000 * \real{##2}}%
        \unitrow{##1}{##2}{##3}{hours}%
    }

    \newcommand{\taxes}{
        \\
        {\bf Subtotal} & & & {\bf \total{cost} DKK} \\
        {\bf Taxes (25\% of \total{cost} DKK)} & & & {\bf \total{moms} DKK} \\
    }

    \renewcommand{\tabcolsep}{0.8ex}
    \setlength\LTleft{0pt}
    \setlength\LTright{0pt}
    \begin{longtable}{@{\extracolsep{\fill}\hspace{\tabcolsep}} l r r r }
    \hline
    {\bf Description of Services} & \multicolumn{1}{c}{\bf Quantity} & \multicolumn{1}{c}{\bf Unit Price} & \multicolumn{1}{c}{\bf Amount} \\*
    \hline\hline
    \endhead
}{
    \hline\hline\hline
    {\bf Total} & & & {\bf \total{topay} DKK} \\
    \end{longtable}
}
