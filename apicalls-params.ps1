#mandatory paramters with sendgrid apikey, mail to and from
param( [Parameter(Mandatory=$true)] $apiKey,[Parameter(Mandatory=$true)] $MailFrom,[Parameter(Mandatory=$true)] $MailTo)
$repo = "https://api.github.com/repos/freeCodeCamp/freeCodeCamp/pulls?state=all"
$addDays = "-7"
$SmtpServer = "smtp.sendgrid.net"

#get date from week ago
$filterDate = (Get-Date).AddDays($addDays)

#convert request from json to psobject
$request = Invoke-WebRequest -Uri $repo 
$json = $request | ConvertFrom-JSON

#filter pulls by date and state in scriptblock
$text =
    {
    Param($state)
    foreach($obj in $json)
    {   
	  $time = $obj.created_at -split "T"
      if  ([dateTime]$time[0] -ge $filterDate -and $obj.state -eq $state)
          {
             "Pull request: " + $obj.number + "`n"
             "State: " + $obj.state + "`n"
             "Created at: " + $obj.created_at + "`n"
             "Title: " + $obj.title + "`n"
             "Url: " + $obj.url + "`n"
             "`n"  
          }
     }
}

#mailing variables
$MailSubject = "Report of pull requests from last week"
$MailBody =@"
 List of pull request from last week:

 OPEN:
 $(Invoke-Command -ScriptBlock $text -ArgumentList "open")
 IN PROGRESS:
 $(Invoke-Command -ScriptBlock $text -ArgumentList "progress")
 CLOSED:
 $(Invoke-Command -ScriptBlock $text -ArgumentList "closed")
"@

#create crendentials
$smtpUser = "apikey"
$smtpPass = ConvertTo-SecureString $apiKey -AsPlainText -Force
$smtpCredential = New-Object System.Management.Automation.PSCredential $smtpUser, $smtpPass

#send mail
function send-mail{
			param($MailFrom, $MailTo, $MailSubject, $MailBody, $SmtpServer, $smtpCredential)
			#preview of email in console
            "`n"
            "sending mail from : " + $MailFrom
            "Sending mail to : " + $MailTo
            "Title : " + $MailSubject
            "Body: " + $MailBody 
            send-MailMessage -from $MailFrom -to $MailTo -subject $MailSubject -body $MailBody -smtpserver $SmtpServer -credential $smtpCredential -port "587"
            }

$job = Start-Job -ScriptBlock ${function:send-mail} -ArgumentList $MailFrom, $MailTo, $MailSubject, $MailBody, $SmtpServer, $smtpCredential
Wait-Job $job
Receive-Job $job