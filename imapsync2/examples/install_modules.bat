
REM $Id: install_modules.bat,v 1.12 2014/05/22 10:16:12 gilles Exp gilles $

@ECHO OFF 

ECHO Installing Perl modules for imapsync
REM CD /D %~dp0

perl -v
IF ERRORLEVEL 1 ECHO Perl needed. Install Strawberry Perl. Get it at http://strawberryperl.com/ ^
  && EXIT /B

REM perl is there

FOR %%M in ( Mail::IMAPClient ^
             File::Copy::Recursive ^
             PAR::Packer ^
             Test::Pod ^
             IO::Socket::IP ^
             IO::Socket::INET ^
             IO::Socket::INET6 ^
             Net::SSLeay ^
             Crypt::SSLeay ^
             Net::SSL IO::Socket::SSL ^
             Digest::MD5 ^
             Digest::HMAC_MD5 ^
             Data::Uniqid URI::Escape ^
             Authen::NTLM ^
             Getopt::ArgvFile ^
             Module::ScanDeps ^
             IO::Tee ^
             ) DO ECHO Updating %%M ^
   & perl -MCPAN -e "install %%M"

REM   & perl -m%%M -e "" || perl -MCPAN -e "install %%M"


ECHO Perl modules for imapsync installed
REM PAUSE


