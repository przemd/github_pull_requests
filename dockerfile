FROM mcr.microsoft.com/powershell:7.2-alpine-3.13

ENV apiKey \
    MailFrom \
    MailTo

COPY apicalls-params.ps1 ./ 

CMD pwsh ./apicalls-params.ps1 -apiKey $apiKey -MailFrom $MailFrom -MailTo $MailTo

