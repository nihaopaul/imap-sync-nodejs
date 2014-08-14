#!/bin/sh

# $Id: tests.sh,v 1.238 2014/05/22 10:02:14 gilles Exp gilles $  

# Example 1:
# CMD_PERL='perl -I./W/Mail-IMAPClient-3.35/lib' sh -x tests.sh

# Example 2:
# To select which Mail-IMAPClient within arguments:
# sh -x tests.sh 2 locallocal 3 locallocal
# This runs locallocal() with Mail-IMAPClient-2.2.9 then
# again with Mail-IMAPClient-3.xx
# 2 means "use Mail-IMAPClient-2.2.9"
# 3 means "use Mail-IMAPClient-3.xx" 


HOST1=${HOST1:-'localhost'}
echo HOST1=$HOST1
HOST2=${HOST2:-'localhost'}
echo HOST2=$HOST2

# most tests use:

# few debugging tests use:
CMD_PERL_2xx='perl -I./W/Mail-IMAPClient-2.2.9'
CMD_PERL_3xx='perl -I./W/Mail-IMAPClient-3.35/lib'

CMD_PERL=${CMD_PERL:-$CMD_PERL_3xx}

#echo $CMD_PERL
#exit

#### Shell pragmas

exec 3>&2 # 
#set -x   # debug mode. See what is running
set -e    # exit on first failure

#### functions definitions

echo3() {
        #echo '#####################################################' >&3
        echo "$@" >&3
}

run_test() {
        echo3 "#### $test_count $1"
        $1
        if test x"$?" = x"0"; then
                echo "$1 passed"
        else
                echo "$1 failed"
        fi
}

run_tests() {
        for t in "$@"; do
                test X"$t" = X3 && CMD_PERL=$CMD_PERL_3xx && continue
                test_count=`expr 1 + $test_count`
                run_test "$t"
                #sleep 1
        done
}


#### Variable definitions

test_count=0

##### The tests functions

perl_syntax() {
        $CMD_PERL -c ./imapsync
}


no_args() {
        $CMD_PERL ./imapsync
}

# list of accounts on petite :

# mailboxes toto -> titi used on first_sync()

# mailboxes tata -> titi used on locallocal()
# mailboxes tata -> titi on most ll_*() tests

# mailbox tete@est.belle used on big size tests:
#                      big_folder()
#                      big_folder_sizes_only()
#                      dprof()

# mailbox big1 big2 used on bigmail tests
#                      ll_bigmail()
#                      ll_memory_consumption

sendtestmessage() {
    email=${1:-"tata"}
    rand=`pwgen 16 1`
    mess='test:'$rand
    cmd="echo $mess""| mail -s ""$mess"" $email"
    echo $cmd
    eval "$cmd"
}


can_send() {
    test X`hostname` = X"plume" && return 0;
    test X`hostname` = X"vadrouille" && return 0;
    test X`hostname` = X"petite" && return 0;
    return 1
}

zzzz() {
        $CMD_PERL -V

}

option_version() {
        $CMD_PERL ./imapsync --version
}


option_tests() {
        $CMD_PERL ./imapsync --tests
}

option_tests_debug() {
        $CMD_PERL ./imapsync --tests_debug
}

option_bad_delete2() {
	! $CMD_PERL ./imapsync --delete 2 --blabla
}

passwords_masked() {
	$CMD_PERL ./imapsync --host1 boumboum --password1 secret --justbanner | grep MASKED
}

passwords_not_masked() {
	$CMD_PERL ./imapsync --host1 boumboum --password1 secret --justbanner --showpasswords| grep secret
}

first_sync_dry() {
        $CMD_PERL ./imapsync \
            --host1 $HOST1 --user1 toto \
            --passfile1 ../../var/pass/secret.toto \
            --host2 $HOST2 --user2 titi \
            --passfile2 ../../var/pass/secret.titi \
            --dry
}

first_sync() {
        $CMD_PERL ./imapsync \
            --host1 $HOST1 --user1 toto \
            --passfile1 ../../var/pass/secret.toto \
            --host2 $HOST2 --user2 titi \
            --passfile2 ../../var/pass/secret.titi
}


locallocal() {
        #can_send && sendtestmessage
        $CMD_PERL  ./imapsync \
         --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi 
}

ll_debug() {
        #can_send && sendtestmessage
        $CMD_PERL  ./imapsync \
         --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
	 --debug --nofoldersizes 
}

ll_debugmemory() {
        can_send && sendtestmessage
        $CMD_PERL  ./imapsync \
         --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
	 --debugmemory --nofoldersizes 
}



ll_nofoldersizes() 
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --nofoldersizes --folder INBOX
}

ll_nofoldersizes_foldersizesatend() 
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --nofoldersizes --foldersizesatend --folder INBOX
}


pidfile() {
         
                $CMD_PERL ./imapsync \
                --justbanner \
                --pidfile /var/tmp/imapsync.pid
                ! test -f /var/tmp/imapsync.pid
}

ll_pidfilelocking() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX --pidfile /var/tmp/imapsync_test_pidfilelocking.pid \
		--pidfilelocking --justconnect
		echo "Exited $?"
		! test -f /var/tmp/imapsync_test_pidfilelocking.pid
		touch /var/tmp/imapsync_test_pidfilelocking.pid
		if $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX --pidfile /var/tmp/imapsync_test_pidfilelocking.pid \
		--pidfilelocking --justconnect; then
			echo "Exited $?"; ! :
		else
			echo "Exited $?"
		fi

		test -f /var/tmp/imapsync_test_pidfilelocking.pid
		rm /var/tmp/imapsync_test_pidfilelocking.pid
}


justbanner() {    
                $CMD_PERL ./imapsync \
                --justbanner
}

nomodules_version() {    
                $CMD_PERL ./imapsync \
                --justbanner \
                --nomodules_version
}



ll_ask_password() {
                { sleep 2; cat ../../var/pass/secret.tata; } | \
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justlogin
}


ll_authmech_PREAUTH() {
		# No PREAUTH on my box
                ! $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata --authmech1 PREAUTH \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justlogin
}


ll_unknow_option() {
                ! $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX --unknow_option
}



ll_timeout() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX --timeout 1
}



ll_timeout_ssl() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX --timeout 5 --ssl1 --ssl2 
}


ll_folder() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop --folder INBOX.Trash 
}

ll_star() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder 'INBOX.backstar\*' --dry --justfolders --debugimap1 --regextrans2 's#\\|\*#_#g'
}

ll_doublequote() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 ks.lamiral.info --user2 tata \
                --passfile2 ../../var/pass/secret.tata \
                --folder 'INBOX."uni"' --debugimap2 --nofoldersizes --justfolders --ssl1 --ssl2
}

ll_doublequote_rev() {
                $CMD_PERL ./imapsync \
                --host1 ks.lamiral.info  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 tata \
                --passfile2 ../../var/pass/secret.tata \
                --foldersizes --ssl1 --ssl2 --justfolders 
}



ll_folder_noexist() {
                ! $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.noexist --folder INBOX.noexist2
}

# Way to check it each time:
# sh -x tests.sh ll_folder_create ll_delete2folders
ll_folder_create() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop --regextrans2 's/yop/newyop/' \
		--justfolders
}

ll_folder_create_INBOX_Inbox() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX --regextrans2 's/INBOX/Inbox/' \
		--justfolders --nofoldersizes
}

ll_folder_create_backslash_backslash() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap.yip --regextrans2 's/yop/newyop/' \
                --sep2 '\\' \
		--justfolders --nofoldersizes --dry 
#--create_folder_old
}




ll_oneemail() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 $HOST2 --user2 titi \
	--passfile2 ../../var/pass/secret.titi \
	--folder INBOX.oneemail
}

ll_debugimap() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.oneemail --debugimap
}

ll_few_emails() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.few_emails
}

ll_few_emails_dev() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.few_emails --nofoldersizes
}

ll_size_null() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.size_null
}

ll_noheader() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.few_emails --useheader '' --debug
}

ll_noheader_force() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.few_emails \
		--useheader '' \
		--skipheader 'Message-Id|Date'
}

ll_addheader() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.addheader --delete2 --expunge2 --addheader
}



ll_usecachemaxage() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --useuid --maxage 3
}



ll_folderrec() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folderrec INBOX.yop  --justfolders
}

ll_folderrec_star() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folderrec 'INBOX.yop.*'  --justfolders
}

ll_change_blank() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders --nofoldersizes
}




ll_folderrec_blank_bug() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folderrec "INBOX.blanc  " 
}

ll_folderrec_blank_bug_2() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folderrec "INBOX.blanc" 
}

ll_folderrec_blank_bug_3() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folderrec '"INBOX.blanc  "'
}



ll_buffersize() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --buffersize 8 
}


ll_justfolders() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders  --nofoldersizes
                echo "sudo rm -rf /home/vmail/titi/.new_folder/"
}

ll_justfolders_foldersizes() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders
                echo "sudo rm -rf /home/vmail/titi/.new_folder/"
}



ll_delete2foldersonly() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders  --nofoldersizes \
                --regextrans2 's,${h1_prefix}(.*),${h2_prefix}NEW${h2_sep}$1,' \
		--regextrans2 's,^INBOX$,${h2_prefix}NEW${h2_sep}INBOX,' \
                --delete2foldersonly '/${h2_prefix}NEW/' --dry
#                --delete2foldersonly '${h2_prefix}NEW'
}

ll_delete2foldersonly_tmp() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders  --nofoldersizes \
                --regextrans2 's,${h1_prefix}(.*),${h2_prefix}NEW_2${h2_sep}$1,' \
		--regextrans2 's,^INBOX$,${h2_prefix}NEW_2${h2_sep}INBOX,' \
                --delete2foldersonly '/${h2_prefix}NEW_2/'
}

ll_delete2foldersbutnot() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders  --nofoldersizes \
                --delete2foldersbutnot 'm{NEW_2|NEW_3|\[abc\]}' \
		--dry
}

ll_delete2foldersonly_NEW_3() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders  --nofoldersizes \
		--regextrans2 's,^INBOX.oneemail$,INBOX.NEW_3.oneemail,' \
		--regextrans2 's,^INBOX.oneemail2$,INBOX.NEW_3.oneemail2,' 

		test -d /home/vmail/titi/.NEW_3.oneemail/  || return 1
		test -d /home/vmail/titi/.NEW_3.oneemail2/  || return 1

                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders  --nofoldersizes \
		--include 'rrrrr' \
                --delete2foldersonly '/^INBOX.NEW_3.oneemail$/'

		! test -d /home/vmail/titi/.NEW_3.oneemail/ || return 1
		test -d /home/vmail/titi/.NEW_3.oneemail2/ || return 1


}


ll_delete2folders() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders  --nofoldersizes \
                --delete2folders 

		! test -d /home/vmail/titi/.NEW_3/ || return 1
}




ll_bug_folder_name_with_blank() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders --fast 
                echo "rm -rf /home/vmail/titi/.bugs/"
}


ll_bug_folder_name_with_backslash() {
# Bug with Mail-IMAPClient-2.2.9
# Fixed using Mail-IMAPClient-3.28
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --fast

#		--folder "INBOX.yop.jj\\kk" 
#		--folder '"INBOX.yop.jj\kk"' --debug --debugimap --regextrans2 's,\\,_,g'
#		--folder "INBOX.yop.jj\\kk" --debug --debugimap1
                echo "sudo rm -rf '/home/vmail/titi/.yop.jj\\kk'"
}



ll_prefix12() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.qqq  \
                --prefix1 INBOX.\
                --prefix2 INBOX. 
}



ll_nosyncinternaldates() {
        can_send && sendtestmessage toto
        $CMD_PERL_3xx ./imapsync \
         --host1 $HOST1  --user1 toto \
         --passfile1 ../../var/pass/secret.toto \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
         --folder INBOX  \
         --nosyncinternaldates  --delete2 --expunge2 
}
# bug:
# $d=""; # no bug with $d=undef
# $imap2->append_string($h2_fold,$string, $h1_flags, $d);
# 3.25 idate  : Sending: 16 APPEND INBOX () "16-Jul-2010 22:09:42 +0200" {428}
# 2.xx idate  : Sending: 62 APPEND INBOX "16-Jul-2010 22:14:00 +0200" {428}
# 3.25 noidate: Sending: 16 APPEND INBOX () "" {428} # Fails: NO IMAP!
# 2.xx noidate: Sending: 62 APPEND INBOX {428}

ll_idatefromheader() {

        # can_send && sendtestmessage

        $CMD_PERL ./imapsync \
         --host1 $HOST1  --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
         --folder INBOX.oneemail2  \
         --idatefromheader  --debug --dry 
}



ll_folder_rev() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 titi \
                --passfile1 ../../var/pass/secret.titi \
                --host2 $HOST2 --user2 tata \
                --passfile2 ../../var/pass/secret.tata \
                --folder INBOX.yop 
}

ll_subscribed()
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --subscribed 
}


ll_nosubscribe() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --subscribed --nosubscribe 
}

ll_justconnect() 
{
                $CMD_PERL ./imapsync    \
                --host2 $HOST2 \
                --host1 $HOST1 \
                --justconnect 
}

ll_justfoldersizes() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfoldersizes
}

ll_justfoldersizes_case_different() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfoldersizes --folder INBOX --regextrans2 's,^INBOX$,iNbOx,'
}

ll_justfoldersizes_case_different_2() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfoldersizes --folder INBOX.yop --regextrans2 's,yop,YoP,'
}



ll_justfoldersizes_noexist() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfoldersizes --folder NoExist --folder INBOX
}




ll_dev_reconnect() 
{
# in another terminal:
#
: <<'EOF'
while :; do 
    killall -v -u vmail imapd; 
    RAND_WAIT=`numrandom .1..5i.1`
    echo sleeping $RAND_WAIT
    sleepenh $RAND_WAIT
done
# or 
while read y; do 
    killall -u vmail imapd; 
done

EOF
        can_send && sendtestmessage
#        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX --useuid \
		--delete2 --expunge2
}

ll_dev_reconnect_ssl_tls() 
{
# in another terminal:
#
: <<'EOF'
while :; do 
    killall -v -u vmail imapd; 
    RAND_WAIT=`numrandom .1..5i.1`
    echo sleeping $RAND_WAIT
    sleepenh $RAND_WAIT
done
# or 
while read y; do
    echo ENTER to kill all imapd
    killall -v -u vmail imapd; 
done

EOF
        can_send && sendtestmessage
#        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
                --host1 $HOST1 --ssl1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --tls2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX --useuid \
		--delete2
}

ll_dev_reconnect_tls() 
{
# in another terminal:
#
: <<'EOF'
while :; do 
    killall -v -u vmail imapd; 
    RAND_WAIT=`numrandom .1..5i.1`
    echo sleeping $RAND_WAIT
    sleepenh $RAND_WAIT
done
# or 
while read y; do
    echo ENTER to kill all imapd
    killall -v -u vmail imapd; 
done

EOF
        can_send && sendtestmessage
#        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
                --host1 $HOST1 --tls1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --tls2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX --useuid \
		--delete2 --debugsleep --debugimap
}




ll_authmd5() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justlogin --authmd5 
}

ll_authmd51() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justlogin --authmd51
}

ll_authmd52() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justlogin --authmd52
}

ll_noauthmd5() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justlogin --noauthmd5 
}


ll_maxage() 
{
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --maxage 1 --folder INBOX
}

ll_maxage_0() 
{
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --maxage 0 --folder INBOX
}

ll_maxage_10000_minage_9999() 
{
	# INTERSECTION: 0 messages
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --maxage 10000 --minage 9999 \
	--folder INBOX --justfoldersizes
}

ll_maxage_9999_minage_10000() 
{
	# UNION: all messages
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --maxage 9999 --minage 10000 \
	--folder INBOX --justfoldersizes
}

ll_maxage_10000_minage_9999_noabletosearch() 
{
	# INTERSECTION: 0 messages
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --maxage 10000 --minage 9999 \
	--folder INBOX --justfoldersizes --noabletosearch
}

ll_maxage_9999_minage_10000_noabletosearch() 
{
	# UNION: all messages
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --maxage 9999 --minage 10000 \
	--folder INBOX --justfoldersizes --noabletosearch
}



ll_maxage_10000() 
{
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --maxage 10000 --folder INBOX
}


ll_maxage_0_debugimap2() 
{
        #can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --maxage 0 --folder INBOX --debugimap2 --nofoldersizes
}



ll_search_ALL() 
{
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --search 'ALL' --folder INBOX
}

ll_search_FLAGGED() 
{
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --search 'FLAGGED' --folder INBOX
}

ll_search_NOT_DELETED() 
{
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --search 'NOT DELETED' --folder INBOX
}


ll_search_SENTSINCE() 
{
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --search 'SENTSINCE 11-Jul-2011' --folder INBOX
}

ll_search_BEFORE_delete2_useuid() 
{
        can_send && sendtestmessage titi
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --search 'BEFORE 29-Sep-2011' --folder INBOX --delete2 --useuid
}

ll_search_SENTBEFORE() 
{
        can_send && sendtestmessage titi
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --search 'SENTBEFORE 31-Dec-2013' --folder INBOX --delete2
}

ll_search_SENTSINCE_and_BEFORE() 
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --search 'SENTSINCE 1-Jan-2010 SENTBEFORE 31-Dec-2013' --folder INBOX --delete2 --dry
}

ll_search_SENTSINCE_and_BEFORE_search2() 
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --search 'SENTSINCE 1-Jan-2010 SENTBEFORE 31-Dec-2013' \
	--search2 'ALL' --folder INBOX --delete2
}




ll_maxage_nonew() 
{
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --maxage 1 --nofoldersizes \
        --folder INBOX.few_emails
}


ll_nosearch_hack() 
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX.few_emails --debugdev --debugimap1 --noabletosearch
}


ll_newmessage()
{
        can_send && sendtestmessage
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --maxage 1 --folder INBOX --nofoldersizes \
	--debugLIST
}

ll_exitwhenover()
{
        can_send && sendtestmessage
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --maxage 1 --folder INBOX --nofoldersizes \
	--exitwhenover 300
}




ll_folder_INBOX()
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX  --noreleasecheck --usecache --delete2 --expunge2
}

ll_dry_folder_missing()
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX  --dry --regextrans2 "s,^INBOX$,noexit,"
}



ll_maxage_9999() 
{
#        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --justfoldersizes --folder INBOX \
        --maxage 9999 
}

ll_maxlinelength() 
{       
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --maxlinelength 8 --nofoldersizes --folder INBOX
}

ll_minmaxlinelength() 
{       
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --minmaxlinelength 1000 --nofoldersizes --folder INBOX
}


ll_maxlinelength_prepa_1()
{
    $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 gilles@est.belle \
        --passfile1 ../../var/pass/secret.gilles_mbox \
        --host2 $HOST2 --user2 tete@est.belle \
        --passfile2 ../../var/pass/secret.tete \
        --folderrec INBOX.Junk --foldersizes --justfolders \
        --usecache --tmpdir /var/tmp --minmaxlinelength 8000 --debugmaxlinelength
}

ll_maxlinelength_prepa_2()
{
    $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tete@est.belle \
        --passfile1 ../../var/pass/secret.tete \
        --host2 ks.lamiral.info --user2 tata \
        --passfile2 ../../var/pass/secret.tata \
	--ssl2 \
        --include INBOX.Junk.20 --foldersizes --nojustfolders \
        --useuid --tmpdir /var/tmp --minmaxlinelength 10 --delete2 --nofastio1 --nofastio2
}



ll_maxsize() 
{       
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --maxsize 10 --nofoldersizes --folder INBOX
}

ll_maxsize_useuid() 
{       
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --maxsize 10 --nofoldersizes --folder INBOX \
                --useuid --debugcache
}

ll_minsize_useuid() 
{       
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --nofoldersizes --folder INBOX \
                --useuid --debugLIST --minsize 500 --maxage 1
}




ll_skipsize() 
{
        
        if can_send; then
                #echo3 Here is plume
		sendtestmessage
        else
                :
        fi
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --skipsize --folder INBOX.yop.yap 
}

ll_skipheader() 
{
        if can_send; then
                #echo3 Here is plume
        	sendtestmessage
        else
                :
        fi
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --skipheader '^X-.*|^Date' --folder INBOX.yop.yap \
                --debug
}



ll_include() 
{
        if can_send; then
                #echo3 Here is plume
	        sendtestmessage
        else
                :
        fi
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --include '^INBOX.yop' 
}

ll_exclude()
{ 
 $CMD_PERL ./imapsync \
 --host1 $HOST1 --user1 tata \
 --passfile1 ../../var/pass/secret.tata \
 --host2 $HOST2 --user2 titi \
 --passfile2 ../../var/pass/secret.titi \
 --exclude '^(?i)INBOX.YOP' --justfolders --nofoldersizes
} 

ll_exclude_2() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --exclude '^INBOX.yop$' --justfolders --nofoldersizes
}

ll_exclude_INBOX() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --exclude '^INBOX' --justfolders --nofoldersizes --dry
}

ll_exclude_blanc_middle() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --exclude '^INBOX.blanc\smiddle' --justfolders --nofoldersizes --dry
}


ll_regextrans2() 
{
       $CMD_PERL ./imapsync \
       --host1 $HOST1 --user1 tata \
       --passfile1 ../../var/pass/secret.tata \
       --host2 $HOST2 --user2 titi \
       --passfile2 ../../var/pass/secret.titi \
       --justfolders \
       --nofoldersizes \
       --regextrans2 's/yop/yoX/' \
       --folder 'INBOX.yop.yap' --debug
}

ll_regextrans2_downcase() 
{
# lowercase the last basename part
# [INBOX.yop.YAP] -> [INBOX.yop.yap] using re [s/(.*)\Q${h1_sep}\E(.+)$/$1${h2_sep}\L$2\E/]
# [INBOX.yop.YAP]                     -> [INBOX.yop.yap]                    

       $CMD_PERL ./imapsync \
       --host1 $HOST1 --user1 tata \
       --passfile1 ../../var/pass/secret.tata \
       --host2 $HOST2 --user2 titi \
       --passfile2 ../../var/pass/secret.titi \
       --justfolders \
       --nofoldersizes \
       --regextrans2 's/(.*)\Q${h1_sep}\E(.+)$/$1${h2_sep}\L$2\E/' \
       --folder 'INBOX.yop.YAP' --justfolders --debug --dry
}

ll_regextrans2_ucfirst() 
{
# lowercase the last basename part
# [INBOX.yop.YAP] -> [INBOX.yop.yap] using re [s/(.*)\Q${h1_sep}\E(.+)$/$1${h2_sep}\L$2\E/]
# [INBOX.yop.YAP]                     -> [INBOX.yop.yap]                    

       $CMD_PERL ./imapsync \
       --host1 $HOST1 --user1 tata \
       --passfile1 ../../var/pass/secret.tata \
       --host2 $HOST2 --user2 titi \
       --passfile2 ../../var/pass/secret.titi \
       --justfolders \
       --nofoldersizes \
       --regextrans2 's/(.*)\Q${h1_sep}\E(.)(.+)$/$1${h2_sep}\u$2\L$3\E/' \
       --folder 'INBOX.yop.YAP' --justfolders --debug --dry
}


ll_regextrans2_slash() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders \
                --nofoldersizes \
                --folder 'INBOX.yop.yap' \
                --sep1 '/' \
                --regextrans2 's,/,_,'

}

ll_regextrans2_subfolder() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders \
                --nofoldersizes \
                --folder 'INBOX.yop.yap' \
		--prefix1 'INBOX.yop.' \
                --regextrans2 's,^${h2_prefix}(.*),${h2_prefix}FOO${h2_sep}$1,' --dry
}



ll_regextrans2_remove_space() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfolders \
                --nofoldersizes \
                --folder 'INBOX.yop.y p' \
                --regextrans2 's, ,,' \
                --dry

}


ll_regextrans2_archive_per_month() 
{
# Bad behavior on Courier
# SENTBEFORE 31-Apr returns nothing
# SENTBEFORE 30 Apr returns messages

		year=2012
		month=Apr
		month_n=04
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --nofoldersizes \
		--search "SENTSINCE 1-$month-$year SENTBEFORE 30-$month-$year" \
                --regextrans2 "s{.*}{INBOX.Archive.$year.$month_n}" 
}



ll_regextrans2_ALLIN() 
{
       $CMD_PERL ./imapsync \
       --host1 $HOST1 --user1 tata \
       --passfile1 ../../var/pass/secret.tata \
       --host2 $HOST2 --user2 titi \
       --passfile2 ../../var/pass/secret.titi \
       --nofoldersizes \
       --regextrans2 's/.*/INBOX.ALLIN/' \
       --folderrec 'INBOX.yop' --delete2
}

ll_regextrans2_ALLIN_usecache() 
{
       $CMD_PERL ./imapsync \
       --host1 $HOST1 --user1 tata \
       --passfile1 ../../var/pass/secret.tata \
       --host2 $HOST2 --user2 titi \
       --passfile2 ../../var/pass/secret.titi \
       --regextrans2 's/.*/INBOX.ALLIN/' \
       --folderrec 'INBOX.yop' --delete2 --usecache --nodelete2duplicates
}

ll_regextrans2_ALLIN_fake() 
{
       $CMD_PERL ./imapsync \
       --host1 $HOST1 --user1 tata \
       --passfile1 ../../var/pass/secret.tata \
       --host2 $HOST2 --user2 titi \
       --passfile2 ../../var/pass/secret.titi \
       --regextrans2 's/.*/INBOX.ALLIN/' \
       --foldersizes \
       --folderrec 'INBOX.yop' --delete2
}


ll_regextrans2_ALLIN_useuid() 
{
       $CMD_PERL ./imapsync \
       --host1 $HOST1 --user1 tata \
       --passfile1 ../../var/pass/secret.tata \
       --host2 $HOST2 --user2 titi \
       --passfile2 ../../var/pass/secret.titi \
       --foldersizes \
       --regextrans2 's/.*/INBOX.ALLIN/' \
       --folderrec 'INBOX.yop' --delete2 --useuid
}



ll_sep2() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap \
                --sep2 '\\' --dry
}

ll_bad_login()
{
    ! $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.toto \
        --host2 $HOST2 --user2 notiti \
        --passfile2 ../../var/pass/secret.titi
   
}

ll_bad_host()
{
    ! $CMD_PERL ./imapsync \
        --host1 badhost --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 badhost --user2 titi \
        --passfile2 ../../var/pass/secret.titi 
   
}

ll_bad_host_ssl()
{
    ! $CMD_PERL ./imapsync \
        --host1 badhost --user1 toto \
        --passfile1 ../../var/pass/secret.toto \
        --host2 badhost --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --ssl1 --ssl2 
}


ll_useheader() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap \
                --useheader 'Message-ID' \
                --dry --debug   
                echo 'rm /home/vmail/titi/.yop.yap/cur/*'
}


ll_useheader_Received() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap \
                --useheader 'Received' \
                --dry --debug   --fast
                echo 'rm /home/vmail/titi/.yop.yap/cur/*'
}

ll_useheader_noheader() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap \
                --useheader 'NoExist' \
                --debug --delete2 --expunge2
                echo 'rm /home/vmail/titi/.yop.yap/cur/*'
}



ll_regexmess() 
{
        if can_send; then
                rm -f /home/vmail/titi/.yop.yap/cur/*
        fi
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap \
                --regexmess 's/\157/O/g' \
                --regexmess 's/p/Z/g' \
                 --debug 
                
        if can_send; then 	
		file=`ls -t /home/vmail/titi/.yop.yap/cur/* | tail -1`
                diff ../../var/imapsync/tests/ll_regexmess/dest_01 $file
                echo 'sudo rm -fv /home/vmail/titi/.yop.yap/cur/*'
	fi
}

ll_regexmess_bad_regex() 
{
        ! $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX.yop.yap \
        --regexmess 'I am BAD' 
}


ll_regexmess_remove_header_Disposition() 
{
#Disposition-Notification-To: Gilles LAMIRAL <gilles.lamiral@laposte.net>
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.regexmess \
		--nofoldersizes \
                --regexmess 's{\A(.*?(?! ^$))(^Disposition-Notification-To:.*?\n)}{$1}gxms' \
                --debugcontent  --debug 
                echo "sudo sh -c 'rm /home/vmail/titi/.regexmess/cur/*'"
}

ll_disarmreadreceipts() 
{
#Disposition-Notification-To: Gilles LAMIRAL <gilles.lamiral@laposte.net>
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.regexmess \
		--nofoldersizes \
                --disarmreadreceipts \
                --debugcontent  --debug 
                echo "sudo sh -c 'rm /home/vmail/titi/.regexmess/cur/*'"
}



ll_regexmess_scwchu() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.scwchu \
                --regexmess 's{\A(.*?(?! ^$))^Date:(.*?)$}{$1Date:$2\nReceived: From; $2}gxms' \
                --skipsize --skipheader 'Received: From;' \
                --debug  
                echo 'rm /home/vmail/titi/.scwchu/cur/*'
}

ll_regexmess_wong() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.scwchu \
                --regexmess 's{\A}{Content-Type: text/plain; charset="big5"\n}gxms' \
                --debugcontent  --debug
                echo "sudo sh -c 'rm /home/vmail/titi/.scwchu/cur/*'"
}

ll_regexmess_wong_2() 
{
#Received: from hkuhp22.hku.hk
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.scwchu \
                --regexmess 's{\A(.*?(?!^$))^(Received: from hkuhp22.hku.hk.*?)$}{$1Content-Type: text/plain; charset="big5"\n$2}gms' \
                --debugcontent  --debug --dry
                echo "sudo sh -c 'rm /home/vmail/titi/.scwchu/cur/*'"
}

ll_flags() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap \
                --debug
                
                echo 'rm /home/vmail/titi/.yop.yap/cur/*'
}

ll_regex_flag() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap \
                --regexflag 's/\\Answered/\$Forwarded/g' --debugflags
                
                echo 'rm -f /home/vmail/titi/.yop.yap/cur/*'
}

ll_regex_flag_bad() 
{
                ! $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap \
                --regexflag 'I am bad' --debugflags
                
                echo 'sudo rm -fv /home/vmail/titi/.yop.yap/cur/*'
}




ll_regex_flag2() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap \
                --debug --regexflag s/\\\\Answered/\\\\Flagged/g 
                
                echo 'sudo rm -fv /home/vmail/titi/.yop.yap/cur/*'
}


ll_regex_flag3() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap \
                --debug --regexflag s/\\\\Answered//g 
                
                echo 'rm -f /home/vmail/titi/.yop.yap/cur/*'
}

ll_regex_flag4() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap --nofoldersizes \
                --regexflag 's/\$label1/\\label1/g' \
                --regexflag "s/\\\$Forwarded//g" --debugflags
                
                echo 'sudo rm -f /home/vmail/titi/.yop.yap/cur/*'
}

ll_regex_flag5() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap \
                --debugflags --regexflag "s/Answered/Flagged/g"
                
                echo 'rm -f /home/vmail/titi/.yop.yap/cur/*'
}


ll_regex_flag6_add_SEEN() 
{
	$CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX.yop.yap \
        --debugflags --regexflag "s/(.*)/\$1 \\\\Seen/"

        echo 'rm -f /home/vmail/titi/.yop.yap/cur/*'
}

ll_regex_flag7_add_SEEN() 
{
	$CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX.yop.yap \
        --debugflags --regexflag 's/(.*)/$1 \\Seen/'

        echo 'rm -f /home/vmail/titi/.yop.yap/cur/*'
}


ll_regex_flag_keep_only() 
{
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX.yop.yap \
                --debug \
                --regexflag 's/(.*)/$1 jrdH8u/' \
                --regexflag 's/.*?(\\Seen|\\Answered|\\Flagged|\\Deleted|\\Draft|jrdH8u)/$1 /g' \
                --regexflag 's/(\\Seen|\\Answered|\\Flagged|\\Deleted|\\Draft|jrdH8u) (?!(\\Seen|\\Answered|\\Flagged|\\Deleted|\\Draft|jrdH8u)).*/$1 /g' \
                --regexflag 's/jrdH8u *//'
                
                echo 'rm -f /home/vmail/titi/.yop.yap/cur/*'
}


ll_tls_justconnect() {
 $CMD_PERL ./imapsync \
  --host1 $HOST1 \
  --host2 $HOST2 \
  --tls1 --tls2 \
  --justconnect  --debugimap
}

ll_tls_justlogin() {
 $CMD_PERL ./imapsync \
  --host1 $HOST1 --user1 tata \
  --passfile1 ../../var/pass/secret.tata \
  --host2 $HOST2 --user2 titi \
  --passfile2 ../../var/pass/secret.titi \
  --tls1 --tls2 \
  --justlogin --debugimap
}


ll_tls_devel() {
   ll_justlogin ll_ssl_justlogin \
&& ll_tls_justconnect ll_tls_justlogin
}

ll_tls() {
 $CMD_PERL ./imapsync \
  --host1 $HOST1 --user1 tata \
  --passfile1 ../../var/pass/secret.tata \
  --host2 $HOST2 --user2 titi \
  --passfile2 ../../var/pass/secret.titi \
  --tls1 --tls2 
}


ll_ssl_justconnect() {
                $CMD_PERL ./imapsync \
		--host1 $HOST1 \
                --host2 $HOST2 \
                --ssl1 --ssl2 \
                --justconnect
}

ll_ssl1_tls2_justconnect() {
        $CMD_PERL ./imapsync \
	 --host1 $HOST1 \
         --host2 $HOST2 \
         --ssl1 --tls2  \
         --justconnect --debugimap
}

ll_tls1_ssl2_justconnect() {
        $CMD_PERL ./imapsync \
	 --host1 $HOST1 \
         --host2 $HOST2 \
         --tls1 --ssl2 \
         --justconnect --debugimap
}

ll_ssl1_tls1_justconnect() {
        $CMD_PERL ./imapsync \
	 --host1 $HOST1 \
         --host2 $HOST2 \
         --ssl1 --tls1   \
         --justconnect --debugimap
}



ll_justconnect_devel() {
   ll_justconnect && ll_tls_justconnect && ll_ssl_justconnect && ll_ssl1_tls2_justconnect && ll_tls1_ssl2_justconnect && ! ll_ssl1_tls1_justconnect
}



ll_ssl_justlogin() {
        $CMD_PERL ./imapsync \
	 --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
         --ssl1 --ssl2 \
         --justlogin
}

ll_ssl_tls_justlogin() {
        $CMD_PERL ./imapsync \
	 --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
         --ssl1 --tls1  --ssl2 --tls2  \
         --justlogin --debug
}

ll_justlogin_devel() {
    ll_justlogin && ll_ssl_justlogin && ll_tls_justlogin && ! ll_ssl_tls_justlogin 
}

ll_ssl() {
        if can_send; then
                #echo3 Here is plume
		sendtestmessage
        else
                :
        fi
        $CMD_PERL ./imapsync \
	 --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
         --ssl1 --ssl2 
}

ll_authmech_PLAIN() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfoldersizes --nofoldersizes \
                --authmech1 PLAIN --authmech2 PLAIN 
}

ll_authmech_PLAIN_ssl() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --ssl1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --ssl2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfoldersizes --nofoldersizes \
                --authmech1 PLAIN --authmech2 PLAIN 
}

ll_authmech_ssl_cmich() {
                $CMD_PERL ./imapsync \
                --host1 cmail.cmich.edu --ssl1 --ssl1_SSL_version SSLv3 \
                --host2 imap.gmail.com --ssl2 \
                --justconnect 
}


ll_authmech_XOAUTH_gmail() {
                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com --ssl1 --user1 imapsync@lab3.dedalusprime.com.br \
                --passfile1 ../../var/pass/secret.xoauth \
                --host2 imap.gmail.com --ssl2 --user2 imapsync@lab3.dedalusprime.com.br \
                --passfile2 ../../var/pass/secret.xoauth \
                --justfoldersizes --nofoldersizes \
                --authmech1 XOAUTH --authmech2 XOAUTH
}



ll_authmech_NTLM() {
                $CMD_PERL -I./W/NTLM-1.09/blib/lib ./imapsync \
                --host1 mail.freshgrillfoods.com --user1 ktraster \
                --passfile1 ../../var/pass/secret.ktraster \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justlogin \
                --debug --authmech1 NTLM

}

ll_authmech_NTLM_domain() {
                $CMD_PERL -I./W/NTLM-1.09/blib/lib ./imapsync \
                --host1 mail.freshgrillfoods.com --user1 ktraster \
                --passfile1 ../../var/pass/secret.ktraster \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justlogin \
                --authmech1 NTLM --domain1 freshgrillfoods.com --debugimap1
}

ll_authmech_NTLM_2() {
                $CMD_PERL -I./W/NTLM-1.09/blib/lib ./imapsync \
                --host1 mail.freshgrillfoods.com --user1 ktraster \
                --passfile1 ../../var/pass/secret.ktraster \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --authmech1 NTLM --dry


}



ll_authuser() {

                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfoldersizes --nofoldersizes \
                --authuser2 titi 
}

ll_authuser_2() {

                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 anything \
                --passfile2 ../../var/pass/secret.titi \
                --justfoldersizes \
                --authuser2 titi --folder INBOX.lalala
}


ll_authmech_LOGIN() {

                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfoldersizes --nofoldersizes \
                --authmech1 LOGIN --authmech2 LOGIN 
}

ll_authmech_CRAMMD5() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --justfoldersizes --nofoldersizes \
                --authmech1 CRAM-MD5 --authmech2 CRAM-MD5
}

ll_delete2() {
        can_send && sendtestmessage titi
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX \
        --delete2 --expunge2
}

ll_delete2_reverse() {
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 titi \
        --passfile1 ../../var/pass/secret.titi \
        --host2 $HOST2 --user2 tata \
        --passfile2 ../../var/pass/secret.tata \
        --folder INBOX \
        --delete2 --expunge2 
}



ll_delete_reverse() {
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 titi \
        --passfile1 ../../var/pass/secret.titi \
        --host2 $HOST2 --user2 tata \
        --passfile2 ../../var/pass/secret.tata \
        --folder INBOX \
        --delete --minage 100 --maxage 300 --noexpungeaftereach
}

ll_delete_reverse_useuid() {
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 titi \
        --passfile1 ../../var/pass/secret.titi \
        --host2 $HOST2 --user2 tata \
        --passfile2 ../../var/pass/secret.tata \
        --folder INBOX \
        --delete --minage 100 --maxage 300 --noexpungeaftereach \
	--useuid
}




ll_maxmessagespersecond() {
	ll_delete_reverse
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX \
	--maxmessagespersecond 3.3
}

ll_maxbytespersecond() {
	ll_delete_reverse
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX \
	--maxbytespersecond 10000
}



ll_delete2_minage() {
        can_send && sendtestmessage titi
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX \
        --delete2 --expunge2 --minage 1
}

ll_delete2_minage_useuid() {
        can_send && sendtestmessage titi
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX \
        --delete2 --uidexpunge2 --minage 1 --useuid
}

ll_delete2_uidexpunge2_implicit() {
        can_send && sendtestmessage titi
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX \
        --delete2 --useuid
}


ll_delete2duplicates() {
        can_send && sendtestmessage titi
        can_send && sendtestmessage tata
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX   \
        --delete2duplicates --uidexpunge2
}

ll_duplicates_across_folders() {
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX.zz_1   \
        --folder INBOX.zz_2 \
        --folder INBOX.zz_3 \
        --skipcrossduplicates --debugcrossduplicates 
}




ll_delete2_dev() {
        can_send && sendtestmessage titi
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX  --nofoldersizes \
        --delete2
}


ll_delete() { 
	echo 11111111111111111111111
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX.oneemail3 --delete

	#find /home/vmail/titi/.oneemail3/ || :
	echo After first sync
	test -f /home/vmail/titi/.oneemail3/cur/* || return 1

	echo 222222222222222222222222
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 titi \
        --passfile1 ../../var/pass/secret.titi \
        --host2 $HOST2 --user2 tata \
        --passfile2 ../../var/pass/secret.tata \
        --folder INBOX.oneemail3 \
        --delete

	echo 3333333333333333333333333
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 titi \
        --passfile1 ../../var/pass/secret.titi \
        --host2 $HOST2 --user2 tata \
        --passfile2 ../../var/pass/secret.tata \
        --folder INBOX.oneemail3 \
        --justfoldersizes

	#find /home/vmail/titi/.oneemail3/ || :
	echo After delete
	! test -f /home/vmail/titi/.oneemail3/cur/* || return 1
	
}



ll_delete_delete2() {
        ! $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 titi \
        --passfile1 ../../var/pass/secret.titi \
        --host2 $HOST2 --user2 tata \
        --passfile2 ../../var/pass/secret.tata \
        --delete --delete2
}


ll_bigmail() {
        $CMD_PERL ./imapsync \
        --host1 $HOST1  --user1 big1 \
        --passfile1 ../../var/pass/secret.big1 \
        --host2 $HOST2 --user2 big2 \
        --passfile2 ../../var/pass/secret.big2 \
        --folder INBOX.bigmail
        echo 'sudo sh -c "rm -v /home/vmail/big2/.bigmail/cur/*"'
}

ll_bigmail_fastio() {
        $CMD_PERL ./imapsync \
        --host1 $HOST1  --user1 big1 \
        --passfile1 ../../var/pass/secret.big1 \
        --host2 $HOST2 --user2 big2 \
        --passfile2 ../../var/pass/secret.big2 \
        --folder INBOX.bigmail --fastio1 --fastio2
        echo 'sudo sh -c "rm -v /home/vmail/big2/.bigmail/cur/*"'
}



ll_memory_consumption() {
        $CMD_PERL ./imapsync \
        --host1 $HOST1  --user1 big1 \
        --passfile1 ../../var/pass/secret.big1 \
        --host2 $HOST2 --user2 big2 \
        --passfile2 ../../var/pass/secret.big2 \
        --folder INBOX.bigmail2 \
	--nofoldersizes
        echo 'sudo sh -c "rm -v /home/vmail/big2/.bigmail2/cur/*"'
}


ll_remove_duplicates() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST1 --user2 tata \
                --passfile2 ../../var/pass/secret.tata \
                --folder INBOX.duplicates --delete2 
}



msw() {
	if can_send; then
        	sendtestmessage toto
	fi
        scp imapsync test.bat test_exe.bat\
            ../../var/pass/secret.toto \
            ../../var/pass/secret.titi \
            ../../var/pass/secret.tata \
            Admin@c:'C:/msys/1.0/home/Admin/imapsync/'

        ssh Admin@c 'C:/msys/1.0/home/Admin/imapsync/test.bat'
	scp Admin@c:'C:/msys/1.0/home/Admin/imapsync/imapsync.exe' .
}

msw2() {
	if can_send; then
        	sendtestmessage toto
	fi
        scp imapsync test_exe.bat\
            ../../var/pass/secret.toto \
            ../../var/pass/secret.titi \
            ../../var/pass/secret.tata \
            Admin@c:'C:/msys/1.0/home/Admin/imapsync/'

        ssh Admin@c 'C:/msys/1.0/home/Admin/imapsync/test_exe.bat'
}


ll_change_characters_gmail() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder "INBOX. f g\h\"i'j " --justfolders \
                --regextrans2 "s/['\"\\\\]/_/g" --regextrans2 's,(/|^) +,$1,g' --regextrans2 's, +(/|$),$1,g'

}

ll_blanc_vs_hyphen_gmail() {
                $CMD_PERL ./imapsync \
                --host1 $HOST1  --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder "INBOX.A-B" --folder "INBOX.A B" --folder "INBOX.A.B" --justfolders
}



xxxxx_gmail() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--nofoldersizes \
		--regextrans2 's,(/|^) +,$1,g' --regextrans2 's, +(/|$),$1,g' \
		--exclude 'INBOX.yop.YAP' \
		--regextrans2 "s,^Messages envoy&AOk-s$,[Gmail]/Messages envoy&AOk-s," \
		--regextrans2 "s,^Sent$,[Gmail]/Sent Mail," \
		--folder 'INBOX.Messages envoy&AOk-s' \
		--folder 'INBOX.Sent' 

}

xxxxx_gmail_useuid() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--nofoldersizes \
		--regextrans2 "s,^Sent$,[Gmail]/Sent Mail," \
		--folder 'INBOX.Sent' --useuid --dry
}

xxxxx_gmail_2() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--nofoldersizes \
                --regextrans2 's,(.*),SMS,'
}

xxxxx_gmail_3() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--nofoldersizes \
                --folder INBOX.few_emails  --debug --useheader Message-ID --delete2 --dry
}

xxxxx_gmail_3_Received() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--nofoldersizes \
                --folder INBOX.few_emails  --debug --useheader Received --delete2 --dry
}


xxxxx_gmail_4_Sent() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
                --folder INBOX.Sent  \
                --regextrans2 's{Sent}{[Gmail]/Messages envoy&AOk-s}' 
}

xxxxx_gmail_5_justfolders() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--justfolders --nofoldersizes \
                --regextrans2 's,(/|^) +,$1,g' --regextrans2 's, +(/|$),$1,g' \
		--regextrans2 "s/[\^]/_/g" --debug
}


xxxxx_gmail_5_justlogin() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--justlogin
}

xxxxx_gmail_5_justlogin_exe() {

                ! ping -c1 imap.gmail.com || ./imapsync_elf_x86.bin \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--justlogin
}

xxxxx_gmail_5_justlogin_SSLv3() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--justlogin --ssl2_SSL_version SSLv3 --justconnect
}

xxxxx_gmail_5_justlogin_SSLv2() {

                ! ping -c1 imap.gmail.com || ! $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--justlogin --ssl2_SSL_version SSLv2
}

xxxxx_gmail_5_justlogin_SSLv23() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--justlogin --ssl2_SSL_version SSLv23
}




xxxxx_gmail_6() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--nofoldersizes \
		--justfolders \
		--regextrans2 "s, +$,,g" --regextrans2 "s, +/,/,g" \
		--exclude INBOX.yop.YAP

#--dry --prefix2 '[Gmail]/'
}

xxxxx_gmail_7() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--nofoldersizes \
                --folder INBOX.yop.yap
}


xxxxx_gmail_8_xlist() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 $HOST2 \
                --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
		--foldersizes \
                --folder INBOX 
}



gmail_xxxxx() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 gilles.lamiral@gmail.com \
                --passfile1 ../../var/pass/secret.gilles_gmail \
                --host2 $HOST2 \
                --user2 tata \
                --passfile2 ../../var/pass/secret.tata \
		--nofoldersizes \
                --dry --justfolders --exclude Gmail --exclude "blanc\ $"
}


gmail() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 gilles.lamiral@gmail.com \
                --passfile1 ../../var/pass/secret.gilles_gmail \
                --host2 $HOST2 \
                --user2 tata \
                --passfile2 ../../var/pass/secret.tata \
                --exclude Gmail --exclude "blanc\ $"
}

gmail_l_tata() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 gilles.lamiral@gmail.com \
                --passfile1 ../../var/pass/secret.gilles_gmail \
                --host2 $HOST2 \
                --user2 tata \
                --passfile2 ../../var/pass/secret.tata \
                --folder INBOX 
}


gmail_justfolders() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 gilles.lamiral@gmail.com \
                --passfile1 ../../var/pass/secret.gilles_gmail \
                --host2 $HOST2 \
                --user2 tata \
                --passfile2 ../../var/pass/secret.tata \
		--justfolders --exclude Gmail --exclude "blanc\ $"
}


gmail_via_stunnel_ks() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 ks.lamiral.info \
                --port1 243 --nossl1 \
                --user1 gilles.lamiral@gmail.com \
                --passfile1 ../../var/pass/secret.gilles_gmail \
                --host2 $HOST2 \
                --user2 tata \
                --passfile2 ../../var/pass/secret.tata \
                --useheader 'Message-Id' \
                --useheader="X-Gmail-Received" \
                --debug --justfolders
}

gmail_gmail() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 gilles.lamiral@gmail.com \
                --passfile1 ../../var/pass/secret.gilles_gmail \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 imapsync.gl@gmail.com \
                --passfile2 ../../var/pass/secret.imapsync.gl_gmail \
                --justfolders --exclude Gmail  --exclude "blanc\ $"

}

gmail_gmail_justconnect() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 gilles.lamiral@gmail.com \
                --passfile1 ../../var/pass/secret.gilles_gmail \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 imapsync.gl@gmail.com \
                --passfile2 ../../var/pass/secret.imapsync.gl_gmail \
                --justconnect

}

gmail_gl_gl2() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 imapsync.gl@gmail.com \
                --passfile1 ../../var/pass/secret.imapsync.gl_gmail \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 imapsync.gl2@gmail.com \
                --passfile2 ../../var/pass/secret.imapsync.gl_gmail \
                --justfolders --exclude Gmail  --exclude "blanc\ $" --dry
}


gmail_gl_gl2_SUB() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 imapsync.gl@gmail.com \
                --passfile1 ../../var/pass/secret.imapsync.gl_gmail \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 imapsync.gl2@gmail.com \
                --passfile2 ../../var/pass/secret.imapsync.gl_gmail \
                --justfolders --nofoldersizes --exclude Gmail --regextrans2 "s,(.*),SUB/\$1,"
}



gmail_gl_gl2_create_folder_old() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 imapsync.gl@gmail.com \
                --passfile1 ../../var/pass/secret.imapsync.gl_gmail \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 imapsync.gl2@gmail.com \
                --passfile2 ../../var/pass/secret.imapsync.gl_gmail \
                --justfolders --exclude Gmail  --exclude "blanc\ $" \
		--create_folder_old --dry --nofoldersizes
}


gmail_gmail_folderfirst() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 gilles.lamiral@gmail.com \
                --passfile1 ../../var/pass/secret.gilles_gmail \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 imapsync.gl@gmail.com \
                --passfile2 ../../var/pass/secret.imapsync.gl_gmail \
		--exclude "blanc\ $" --exclude Gmail \
                --justfolders --folderfirst INBOX --folderfirst zz  --folderlast "[Gmail]/All Mail"

}


gmail_gmail_INBOX() {
                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 gilles.lamiral@gmail.com \
                --passfile1 ../../var/pass/secret.gilles_gmail \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 imapsync.gl@gmail.com \
                --passfile2 ../../var/pass/secret.imapsync.gl_gmail \
                --folder INBOX 
		#--dry # --debug --debugimap # --authmech1 LOGIN
}

gmail_gmail_3_delete() {
                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 imapsync.gl@gmail.com \
                --passfile1 ../../var/pass/secret.imapsync.gl_gmail \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 gilles.lamiral@gmail.com \
                --passfile2 ../../var/pass/secret.gilles_gmail \
                --folder '[Gmail]/All Mail' --delete
		# '[Gmail]/All Mail' is not expunge by default!

}

gmail_gmail_4_tls() {
                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1  \
                --user1 gilles.lamiral@gmail.com \
                --passfile1 ../../var/pass/secret.gilles_gmail \
                --host2 imap.gmail.com \
                --ssl2 --tls2 --port2 993 \
                --user2 imapsync.gl@gmail.com \
                --passfile2 ../../var/pass/secret.imapsync.gl_gmail \
                --folder INBOX 
		#--dry # --debug --debugimap # --authmech1 LOGIN
}


gmail_gmail_5_exclude_only_Gmail() {

                ! ping -c1 imap.gmail.com || $CMD_PERL ./imapsync \
                --host1 imap.gmail.com \
                --ssl1 \
                --user1 gilles.lamiral@gmail.com \
                --passfile1 ../../var/pass/secret.gilles_gmail \
                --host2 imap.gmail.com \
                --ssl2 \
                --user2 imapsync.gl@gmail.com \
                --passfile2 ../../var/pass/secret.imapsync.gl_gmail \
                --nofoldersizes --folderrec "[Gmail]" --exclude "\[Gmail\]$"

}


yahoo_xxxx_login() {
                ! ping -c1 imap.mail.yahoo.com || $CMD_PERL ./imapsync \
                --host1 imap.mail.yahoo.com \
                --ssl1 \
                --user1 glamiral \
                --passfile1 ../../var/pass/secret.gilles_yahoo \
                --host2 $HOST2 \
                --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
		--justlogin 
}

yahoo_xxxx() {
# Yahoo works only with ssl (november 2011)
# Could do plain port 143 before
                ! ping -c1 imap.mail.yahoo.com || $CMD_PERL ./imapsync \
                --host1 imap.mail.yahoo.com \
		--ssl1 \
                --user1 glamiral \
                --passfile1 ../../var/pass/secret.gilles_yahoo \
                --host2 $HOST2 \
                --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
		--sep1 '.'

}




allow3xx() {
                $CMD_PERL  ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
		--allow3xx --justlogin 
}

noallow3xx() {
                $CMD_PERL_3xx ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
		--noallow3xx --justlogin 
}


archiveopteryx_1() {
	if can_send; then
                #echo3 Here is plume
                sendtestmessage je@lupus.aox.org
        else
                :
        fi
                $CMD_PERL  ./imapsync \
                --host1 lupus.aox.org --user1 je \
                --passfile1 ../../var/pass/secret.aox_je \
                --host2 lupus.aox.org --user2 je \
                --passfile2 ../../var/pass/secret.aox_je \
                --folder INBOX --regextrans2 's/INBOX/copy/' 
}

dkimap_1() {
                $CMD_PERL  ./imapsync \
                --host1 Mail.fourfrontsales.com --user1 dktest \
                --passfile1 ../../var/pass/secret.dktest \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
                --folder INBOX/dkimap --regextrans2 's/INBOX.INBOX./INBOX./'  \
		--foldersize --nouid1
}

ll_justlogin() {
                $CMD_PERL  ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 titi \
                --passfile2 ../../var/pass/secret.titi \
		--justlogin 
}

ll_justlogin_backslash_char() {
# Look in the file ../../var/pass/secret.tptp to see 
# strange \ character behavior
                $CMD_PERL  ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 tptp@est.belle \
                --passfile2 ../../var/pass/secret.tptp \
		--justlogin 
}

ll_justlogin_dollar_char() {
                $CMD_PERL  ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 dollar \
                --passfile2 ../../var/pass/secret.dollar \
		--justlogin
}

ll_justlogin_equal_char() {
                $CMD_PERL  ./imapsync \
                --host1 $HOST1 --user1 tata \
                --passfile1 ../../var/pass/secret.tata \
                --host2 $HOST2 --user2 equal \
                --passfile2 ../../var/pass/secret.equal \
		--justlogin --debugimap2
}




ll_usecache() {
        if can_send; then
                sendtestmessage
        else
                :
        fi
	
        $CMD_PERL  ./imapsync \
         --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
         --usecache --nofoldersizes \
         --folder INBOX 
}

ll_usecache_all() {
        if can_send; then
                sendtestmessage
        else
                :
        fi
	
        $CMD_PERL  ./imapsync \
         --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
         --usecache --nofoldersizes
}




ll_nousecache() {
        if can_send; then
                sendtestmessage
        else
                :
        fi
	
        $CMD_PERL  ./imapsync \
         --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
         --nousecache --nofoldersizes \
         --folder INBOX 
}


ll_usecache_INBOX() {
        if can_send; then
                sendtestmessage
        else
                :
        fi
	
        $CMD_PERL  ./imapsync \
         --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
         --usecache --foldersizes \
         --folder INBOX 
}




ll_usecache_noheader() {
        if can_send; then
                sendtestmessage
        else
                :
        fi
	
        $CMD_PERL  ./imapsync \
         --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
         --usecache \
         --folder INBOX --useheader ''
}

ll_usecache_debugcache() {
        if can_send; then
                sendtestmessage
        else
                :
        fi
	
        $CMD_PERL  ./imapsync \
         --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
         --usecache --nofoldersizes \
         --folder INBOX --useheader '' --debugcache
}

ll_usecache_debugcache_useuid() {
        if can_send; then
                sendtestmessage
        else
                :
        fi
	
        $CMD_PERL  ./imapsync \
         --host1 $HOST1 --user1 tata \
         --passfile1 ../../var/pass/secret.tata \
         --host2 $HOST2 --user2 titi \
         --passfile2 ../../var/pass/secret.titi \
         --usecache --nofoldersizes \
         --folder INBOX --useheader '' --debugcache --useuid
}

ll_useuid_INBOX() 
{
        if can_send; then
                sendtestmessage
        else
                :
        fi
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX \
        --delete2 \
        --useuid
        echo 'rm /home/vmail/titi/.yop.yap/cur/*'
}

ll_useuid() 
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX.useuid \
        --delete2 \
        --useuid
}

ll_useuid_all() 
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --delete2 --useuid --nofoldersizes
}


ll_useuid_nousecache() 
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX.useuid \
        --useuid --nousecache --debugcache
        echo 'rm /home/vmail/titi/.yop.yap/cur/*'
}

ll_fastio() 
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX --fastio1 --fastio2
}

ll_nofastio() 
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
        --folder INBOX --nofastio1 --nofastio2
}

l_office365()
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 imap-mail.outlook.com --ssl2 --user2 gilles.lamiral@outlook.com \
        --passfile2 ../../var/pass/secret.outlook.com \
        --folder INBOX --tmpdir /var/tmp --usecache --regextrans2 's/INBOX/tata/' --delete2 --expunge2
}

l_office365_bigfolders()
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 imap-mail.outlook.com --ssl2 --user2 gilles.lamiral@outlook.com \
        --passfile2 ../../var/pass/secret.outlook.com \
        --tmpdir /var/tmp --useuid --include Junk.20
}



l_office365_maxline()
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 imap-mail.outlook.com --ssl2 --user2 gilles.lamiral@outlook.com \
        --passfile2 ../../var/pass/secret.outlook.com \
        --tmpdir /var/tmp --usecache --include Junk.2013 --maxlinelength 16000 --debugmaxlinelength
}

l_office365_maxline_2()
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 imap-mail.outlook.com --ssl2 --user2 gilles.lamiral@outlook.com \
        --passfile2 ../../var/pass/secret.outlook.com \
        --tmpdir /var/tmp --usecache \
	--folder INBOX  --regextrans2 's/INBOX/tata/' \
	--minmaxlinelength 8000 --debugmaxlinelength
}

# Only available on ks2 (filtered by a firewall)
l_exchange_maxline() 
{
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 correu.quopiam.com --ssl2 --user2 utest@quopiam.com \
        --passfile2 ../../var/pass/secret.quopiam.com \
        --tmpdir /var/tmp --usecache \
	--folder INBOX  --regextrans2 's/INBOX/longlines/' \
	--minmaxlinelength 10000 --maxlinelength 11000 --debugmaxlinelength 
}

##########################
# specific tests
##########################


courier_45() {
        $CMD_PERL ./imapsync \
        --host1 imap.timeweb.ru --user1 imaptest@avanta-consulting.ru  \
        --passfile1 ../../var/pass/secret.avanta \
        --host2 $HOST2 --user2 tobbit \
        --passfile2 ../../var/pass/secret.tobbit \
        --folder INBOX
}

courier_45_reverse() {
        $CMD_PERL ./imapsync \
        --host2 imap.timeweb.ru --user2 imaptest@avanta-consulting.ru  \
        --passfile2 ../../var/pass/secret.avanta \
        --host1 $HOST2 --user1 tobbit \
        --passfile1 ../../var/pass/secret.tobbit \
        --folder INBOX
}

courier_45_reverse_empty() {
        $CMD_PERL ./imapsync \
        --host2 imap.timeweb.ru --user2 imaptest@avanta-consulting.ru  \
        --passfile2 ../../var/pass/secret.avanta \
        --host1 $HOST2 --user1 empty \
        --passfile1 ../../var/pass/secret.empty \
        --folder INBOX --delete2
}



tobbit_11() {
	$CMD_PERL ./imapsync \
	--host1 217.22.84.74  --user1 Test_IMAP \
	--passfile1 ../../var/pass/secret.tobbit \
	--host2 localhost --user2 tobbit \
	--passfile2 ../../var/pass/secret.tobbit \
	--folder INBOX --sep1 / --prefix1 '' \
        --nofoldersizes --useuid --idatefromheader
}

tobbit_12() {
	$CMD_PERL ./imapsync \
	--host1 217.22.84.74  --user1 Test_IMAP \
	--passfile1 ../../var/pass/secret.tobbit \
	--host2 localhost --user2 tobbit \
	--passfile2 ../../var/pass/secret.tobbit \
	--folder INBOX --sep1 / --prefix1 '' \
        --nofoldersizes --useuid --idatefromheader --nocheckmessageexists
}

tobbit_21() {
	$CMD_PERL ./imapsync \
	--host1 217.22.84.74  --user1 Test_IMAP \
	--passfile1 ../../var/pass/secret.tobbit \
	--host2 localhost --user2 tobbit \
	--passfile2 ../../var/pass/secret.tobbit \
	--folder toto --sep1 / --prefix1 '' \
        --nofoldersizes --useuid --idatefromheader
}

tobbit_22() {
	$CMD_PERL ./imapsync \
	--host1 217.22.84.74  --user1 Test_IMAP \
	--passfile1 ../../var/pass/secret.tobbit \
	--host2 localhost --user2 tobbit \
	--passfile2 ../../var/pass/secret.tobbit \
	--folder toto --sep1 / --prefix1 '' \
        --nofoldersizes --useuid --idatefromheader --nocheckmessageexists
}


exchange_hoch_1() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 ex.fhstp.ac.at --ssl2 --user2 nscdummy@fhstp.local \
	--passfile2 ../../var/pass/secret.fhstp \
	--folder INBOX.oneemail  --debug --delete2
}

exchange_hoch_2() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 ex.fhstp.ac.at --ssl2 --user2 nscdummy@fhstp.local \
	--passfile2 ../../var/pass/secret.fhstp \
	--folder INBOX.oneemail  --dry --debugflags --debug --nofilterflags
}

exchange_hoch_3() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 ex.fhstp.ac.at --ssl2 --user2 nscdummy2@fhstp.local \
	--passfile2 ../../var/pass/secret.fhstp \
	--folder INBOX.few_emails --debugflags --debug  --regexflag 's#\$Forwarded#\$MDNSent#'
}


dbmail_uid() {
	# --useuid alone does not work on dbmaikl server 2.2.17 ready to run
        # because uids are += 2 and uidnext is in fact uidnext + 1

        if can_send; then
                sendtestmessage
        else
                :
        fi
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 182.236.127.31 --user2 imapsynctest \
	--passfile2 ../../var/pass/secret.dbmail \
	--folder INBOX --fast --delete2  --expunge2 \
        --usecache --useuid --nocacheaftercopy


}

dbmail_nocacheaftercopy() {
	# Does work
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 182.236.127.31 --user2 imapsynctest \
	--passfile2 ../../var/pass/secret.dbmail \
	--folder INBOX --fast --delete2  --expunge2 --usecache --nocacheaftercopy
}

dbmail_nocache() {
	# Does work
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 182.236.127.31 --user2 imapsynctest \
	--passfile2 ../../var/pass/secret.dbmail \
	--folder INBOX --fast --delete2  --expunge2
}




bluehost2() {
$CMD_PERL ./imapsync \
                --host1 imap.mail.yahoo.com --tls1 \
                --user1   dalton@piila.com \
                --passfile1 ../../var/pass/secret.bluehost2 \
                --host2 box766.bluehost.com --ssl2 \
                --user2  dalton@piila.com \
                --passfile2 ../../var/pass/secret.bluehost2 \
		--sep1 '/'  --useuid  --regextrans2 's/Inbox/INBOX/' --regextrans2 's,/,_,' 
}

bluehost() {
$CMD_PERL ./imapsync \
                --host1 imap.mail.yahoo.com --tls1 \
                --user1  pii@piila.com \
                --passfile1 ../../var/pass/secret.bluehost \
                --host2 box766.bluehost.com --ssl2 \
                --user2 pii@piila.com \
                --passfile2 ../../var/pass/secret.bluehost \
		--sep1 '/'  --usecache --useuid --regextrans2 's/Inbox/INBOX/'
}

b2btech_1() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 pod51008.outlook.com \
	--user2 TestGilles@uncc.edu \
	--passfile2 ../../var/pass/secret.b2btech --tls2 \
	--useheader Message-Id --useheader Message-ID --fast --delete2 --expunge2 \
	--folder INBOX.oneemail --folder INBOX.few_emails --folder INBOX.Junk


}

Otilio() {
	$CMD_PERL ./imapsync \
	--host1 imap.gmail.com --ssl1 --user1 jacarmona@eurotyre.es \
	--passfile1 ../../var/pass/secret.Otilio1 \
	--host2 mail.eurotyre.es --user2 josedemo@eurotyre.es \
	--passfile2 ../../var/pass/secret.Otilio2 \
	--folder INBOX  --nofoldersizes
}

Otilio2() {
	$CMD_PERL ./imapsync \
	--host1 imap.gmail.com --ssl1 --user1 jacarmona@eurotyre.es \
	--passfile1 ../../var/pass/secret.Otilio1 \
	--host2 $HOST2 --user2 titi \
        --passfile2 ../../var/pass/secret.titi \
	--useuid --folder INBOX  --nofoldersizes 
}

Otilio3() {
	$CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
	--host2 mail.eurotyre.es --user2 josedemo@eurotyre.es \
	--passfile2 ../../var/pass/secret.Otilio2 \
	--folder INBOX  --nofoldersizes --regextrans2 's,INBOX,INBOX/delete_me,g'
}


Giancarlo_1() {
	$CMD_PERL ./imapsync \
	--host1 87.241.29.226 --user1 "Diego@studiobdp.local" \
	--passfile1 ../../var/pass/secret.Giancarlo  \
	--host2 $HOST1  --user2 tata \
	--passfile2 ../../var/pass/secret.tata \
	--regextrans2 's/.*/INBOX.Giancarlo/'  \
	--nofoldersizes --useuid
}

godaddy_1() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 imap.secureserver.net --user2 migrationtest@overnightmac.com \
	--passfile2 ../../var/pass/secret.overnightmac --tls2 \
	--folder INBOX.oneemail --folder INBOX.few_emails
}

godaddy_2() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 imap.secureserver.net --user2 migrationtest@overnightmac.com \
	--passfile2 ../../var/pass/secret.overnightmac --tls2 \
	--folder INBOX.Junk --debug
}




mailenable_1() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 email.avonvalley.wilts.sch.uk --user2 "GLamiral" \
	--passfile2 ../../var/pass/secret.avonvalley  \
	--sep2 / --prefix2 ''  --useuid \
	--folder INBOX --folder INBOX.Junk --folder INBOX.few_emails \
	--delete2 --expunge2
}

mailenable_2_justfolders() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 email.avonvalley.wilts.sch.uk --user2 "GLamiral" \
	--passfile2 ../../var/pass/secret.avonvalley  \
	--sep2 / --prefix2 ''  --useuid \
	--justfolders --exclude "Gmail" --exclude ' '
}


mailenable_3_reverse() {
	$CMD_PERL ./imapsync \
	--host2 $HOST1  --user2 tata \
	--passfile2 ../../var/pass/secret.tata \
	--host1 email.avonvalley.wilts.sch.uk --user1 "GLamiral" \
	--passfile1 ../../var/pass/secret.avonvalley  \
	--sep1 / --prefix1 ''  \
	--folder few_emails  \
	--delete2 --expunge2 --debug --useuid
}







mailenable_21_host1() {
	$CMD_PERL ./imapsync \
	--host1 elix-irr.com --user1 "greg.watson" \
	--passfile1 ../../var/pass/secret.greg.watson  \
	--host2 $HOST1  --user2 zzz \
	--passfile2 ../../var/pass/secret.zzz \
	--sep1 / --prefix1 '' \
	--delete2 --expunge2 --useuid

}

mailenable_22_host2() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 elix-irr.com --user2 "greg.watson" \
	--passfile2 ../../var/pass/secret.greg.watson  \
	--sep2 / --prefix2 ''  \
	--folder INBOX.Junk --folder INBOX --folder INBOX.few_emails \
	--useuid --debugLIST
}



bug_zero_byte() {
	$CMD_PERL ./imapsync \
	--host1 buzon.us.es  --user1 rafaeltovar \
	--passfile1 ../../var/pass/secret.rafaeltovar \
	--host2 $HOST2 --user2 titi \
	--passfile2 ../../var/pass/secret.titi \
	--folder INBOX --regextrans2 s/INBOX/INBOX.rafaeltovar/
}

exchange_1() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 mail.ethz.ch --ssl2 --user2 glamiral \
	--passfile2 ../../var/pass/secret.ethz.ch \
	--folder INBOX.few_emails \
	--debugflags  \
	--useheader 'MESSAGE-ID' --delete2 --expunge2 \
	--nofilterflags \

	#--regexflag 's/\$\w+//g'
        #-maxage 1
}

exchange_2() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 mail.ethz.ch --ssl2 --user2 glamiral \
	--passfile2 ../../var/pass/secret.ethz.ch \
	--folder INBOX.Junk --useuid
}

exchange_3_delete2() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 mail.ethz.ch --ssl2 --user2 glamiral \
	--passfile2 ../../var/pass/secret.ethz.ch \
	--folder INBOX.Junk --useuid --delete2
}


exchange_4_useheader_Received() {
	$CMD_PERL ./imapsync \
	--host1 $HOST1  --user1 tata \
	--passfile1 ../../var/pass/secret.tata \
	--host2 mail.ethz.ch --ssl2 --user2 glamiral \
	--passfile2 ../../var/pass/secret.ethz.ch \
	--folder INBOX.yop.yap \
	--delete2 --expunge2 \
	--useheader 'Received'


# --useheader 'Received'

	#--regexflag 's/\$\w+//g'
        #-maxage 1
}


jong_1() {
$CMD_PERL ./imapsync \
    --host1 mail.y-publicaties.nl --user1 gillesl --passfile1 ../../var/pass/secret.jong \
    --host2 $HOST2 --user2 titi --passfile2 ../../var/pass/secret.titi --sep1 /  --prefix1 '' \
    --delete2 --expunge2 --expunge1 --expunge \
    --foldersizes --folder Junk/2009 --useuid
# --debugimap1 --dry
}

jong_1_reverse() {
$CMD_PERL ./imapsync \
    --host2 mail.y-publicaties.nl --user2 gillesl --passfile2 ../../var/pass/secret.jong \
    --host1 $HOST2 --user1 gilles@est.belle --passfile1 ../../var/pass/secret.gilles_mbox \
    --sep2 /  --prefix2 ''  \
    --folder INBOX.Junk.2009 --delete2 --expunge2 --expunge1 --expunge --useuid
#--nofoldersizes 
# --debugimap1 --dry
}

jong_1_lastuid()
{
        can_send && sendtestmessage
        $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 tata \
        --passfile1 ../../var/pass/secret.tata \
        --host2 mail.y-publicaties.nl --user2 gillesl \
        --passfile2 ../../var/pass/secret.jong \
	--sep2 /  --prefix2 '' \
        --folder INBOX --nofoldersizes --maxage 1
}



jong_2_delete() {
$CMD_PERL ./imapsync \
    --host1 mail.y-publicaties.nl --user1 gillesl --passfile1 ../../var/pass/secret.jong \
    --host2 $HOST2 --user2 titi --passfile2 ../../var/pass/secret.titi --sep1 /  --prefix1 '' \
    --delete --folder INBOX
# --debugimap1 --dry
}

gigamail_1() {
$CMD_PERL ./imapsync \
    --host1 mail.gigamail.nl --user1 testbox@gigamail.nl --passfile1 ../../var/pass/secret.gigamail \
    --host2 $HOST2 --user2 titi --passfile2 ../../var/pass/secret.titi \
    --sep1 . --prefix1 ''

}

gigamail_2() {
$CMD_PERL ./imapsync \
    --host1 mail.gigamail.nl --user1 testbox@gigamail.nl --passfile1 ../../var/pass/secret.gigamail \
    --host2 $HOST2 --user2 titi --passfile2 ../../var/pass/secret.titi
}

gigamail_3() {
$CMD_PERL ./imapsync \
    --host1 mail.gigamail.nl --user1 testbox@gigamail.nl --passfile1 ../../var/pass/secret.gigamail \
    --host2 $HOST2 --user2 titi --passfile2 ../../var/pass/secret.titi --sep1 .
}

sunone_gmail()
{
    date1=`date`
    { $CMD_PERL ./imapsync \
        --host1 mailhost.marymount.edu --ssl1 --user1 adoe \
        --passfile1 ../../var/pass/secret.adoe \
        --host2 imap.googlemail.com --ssl2 --user2 adoe@marymount.edu \
        --passfile2 ../../var/pass/secret.adoegmail \
        --useheader Message-ID --no-authmd5 \
	--exclude Trash
    }
    date2=`date`
    echo3 "[$date1] [$date2]"
}

sunone_gmail_2()
{
    date1=`date`
    { $CMD_PERL ./imapsync \
        --host1 mailhost.marymount.edu --ssl1 --user1 jharsh@marymount.edu \
        --passfile1 ../../var/pass/secret.jharsh \
        --host2 imap.googlemail.com --ssl2 --user2 jharsh@marymount.edu \
        --passfile2 ../../var/pass/secret.jharsh \
        --useheader Message-ID --no-authmd5 \
	--folder bug
    }
    date2=`date`
    echo3 "[$date1] [$date2]"
}

big_folder()
{
    date1=`date`
    { $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 gilles@est.belle \
        --passfile1 ../../var/pass/secret.gilles_mbox \
        --host2 $HOST2 --user2 tete@est.belle \
        --passfile2 ../../var/pass/secret.tete \
        --include INBOX.Junk.20 \
        --usecache --tmpdir /var/tmp --debugmemory  || \
    true
    }
    date2=`date`
    echo3 "[$date1] [$date2]"
}

big_folder_useuid()
{
    date1=`date`
    { $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 gilles@est.belle \
        --passfile1 ../../var/pass/secret.gilles_mbox \
        --host2 $HOST2 --user2 tete@est.belle \
        --passfile2 ../../var/pass/secret.tete \
        --include INBOX.Junk.20 --foldersizes \
        --useuid --tmpdir /var/tmp --delete2 || \
    true
    }
    date2=`date`
    echo3 "[$date1] [$date2]"
}




big_folder_sizes_only()
{
    date1=`date`
    { $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 gilles@est.belle \
        --passfile1 ../../var/pass/secret.gilles_mbox \
        --host2 $HOST2 --user2 tete@est.belle \
        --passfile2 ../../var/pass/secret.tete \
        --justfoldersizes  --folder INBOX.Junk.2010 || \
    true
    }
    date2=`date`
    echo3 "[$date1] [$date2]"
}

big_folder_fast()
{
    date1=`date`
    { $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 gilles@est.belle \
        --passfile1 ../../var/pass/secret.gilles_mbox \
        --host2 $HOST2 --user2 tete@est.belle \
        --passfile2 ../../var/pass/secret.tete \
        --folder INBOX.Junk.2010 \
        --fast || \
    true
    }
    date2=`date`
    echo3 "[$date1] [$date2]"
}

big_folder_fast2()
{
    date1=`date`
    { $CMD_PERL ./imapsync \
        --host1 $HOST1 --user1 gilles@est.belle \
        --passfile1 ../../var/pass/secret.gilles_mbox \
        --host2 $HOST2 --user2 tete@est.belle \
        --passfile2 ../../var/pass/secret.tete \
        --folder INBOX.Junk \
        --fast || \
    true
    }
    date2=`date`
    echo3 "[$date1] [$date2]"
    echo2 'rm -f /home/vmail/tete/.Junk/cur/*'
}


dprof_justfoldersizes()
{
    date1=`date`
    { $CMD_PERL -d:DProf ./imapsync \
        --host1 $HOST1 --user1 gilles@est.belle \
        --passfile1 ../../var/pass/secret.gilles_mbox \
        --host2 $HOST2 --user2 tete@est.belle \
        --passfile2 ../../var/pass/secret.tete \
        --justfoldersizes  --folder INBOX.Junk || \
    true
    }
    date2=`date`
    echo3 "[$date1] [$date2]"
    mv tmon.out dprof_justfoldersizes_tmon.out
    dprofpp -O 30    dprof_justfoldersizes_tmon.out
    dprofpp -O 30 -I dprof_justfoldersizes_tmon.out
}


dprof_bigfolder()
{
    date1=`date`
    { $CMD_PERL -d:DProf ./imapsync \
        --host1 $HOST1 --user1 gilles@est.belle \
        --passfile1 ../../var/pass/secret.gilles_mbox \
        --host2 $HOST2 --user2 tete@est.belle \
        --passfile2 ../../var/pass/secret.tete \
        --nofoldersizes  --folder INBOX.15_imapsync.imapsync-list || \
    true
    }
    date2=`date`
    echo3 "[$date1] [$date2]"
    mv tmon.out      dprof_bigfolder_tmon.out
    dprofpp -O 30    dprof_bigfolder_tmon.out
    dprofpp -O 30 -I dprof_bigfolder_tmon.out
}

dprof_bigmail()
{
    date1=`date`
    { $CMD_PERL -d:DProf ./imapsync \
      --host1 $HOST1  --user1 tata \
      --passfile1 ../../var/pass/secret.tata \
      --host2 $HOST2 --user2 titi \
      --passfile2 ../../var/pass/secret.titi \
      --folder INBOX.bigmail
      echo 'sudo sh -c "rm -v /home/vmail/titi/.bigmail/cur/*"' || \
    true
    }
    date2=`date`
    echo3 "[$date1] [$date2]"
    mv tmon.out      dprof_bigmail_tmon.out
    dprofpp -O 30    dprof_bigmail_tmon.out
    dprofpp -O 30 -I dprof_bigmail_tmon.out
}



##########################
##########################

# Tests list

mandatory_tests='
no_args
option_version
option_tests
option_tests_debug
option_bad_delete2 
passwords_masked 
passwords_not_masked 
first_sync_dry 
first_sync 
locallocal 
pidfile 
ll_pidfilelocking 
justbanner 
nomodules_version
xxxxx_gmail
gmail_xxxxx
gmail 
gmail_gmail 
gmail_gmail_INBOX 
gmail_gmail_folderfirst
yahoo_xxxx
ll_unknow_option 
ll_ask_password 
ll_bug_folder_name_with_blank 
ll_timeout 
ll_folder
ll_folder_noexist
ll_oneemail
ll_buffersize 
ll_justfolders 
ll_prefix12 
ll_nosyncinternaldates 
ll_idatefromheader 
ll_folder_rev 
ll_subscribed 
ll_nosubscribe 
ll_justfoldersizes 
ll_authmd5 
ll_authmd51
ll_authmd52
ll_noauthmd5 
ll_maxage 
ll_maxsize 
ll_skipsize 
ll_skipheader 
ll_include 
ll_exclude 
ll_exclude_INBOX
ll_regextrans2 
ll_regextrans2_subfolder
ll_sep2 
ll_bad_login 
ll_bad_host 
ll_bad_host_ssl 
ll_useheader 
ll_useheader_noheader 
ll_regexmess 
ll_regexmess_bad_regex
ll_regexmess_scwchu 
ll_flags 
ll_regex_flag 
ll_regex_flag_bad
ll_regex_flag_keep_only 
ll_justconnect 
ll_justlogin 
ll_justconnect_devel
ll_ssl 
ll_ssl_justconnect 
ll_ssl_justlogin 
ll_tls_justconnect 
ll_tls_justlogin 
ll_tls 
ll_authmech_PLAIN 
ll_authmech_XOAUTH_gmail
ll_authmech_LOGIN 
ll_authmech_CRAMMD5 
ll_authmech_PREAUTH
ll_authuser 
ll_delete_delete2
ll_delete2 
ll_delete 
ll_folderrec 
allow3xx 
noallow3xx
ll_memory_consumption
ll_newmessage
ll_usecache
ll_usecache_noheader
ll_usecache_debugcache
ll_nousecache
ll_delete2foldersonly_NEW_3
ll_delete2foldersonly
ll_delete2foldersonly_tmp
ll_delete2foldersbutnot
ll_folder_create
ll_folder_create_INBOX_Inbox
ll_delete2folders
ll_useuid
ll_useuid_nousecache
ll_noheader_force
ll_noheader
'

other_tests='
archiveopteryx_1 
msw
msw2
ll_bigmail 
ll_justlogin_backslash_char
option_tests_debug
'

l() {
	echo "$mandatory_tests" "$other_tests"
}

# mandatory tests

run_tests perl_syntax


# All tests

test $# -eq 0 && run_tests $mandatory_tests


# selective tests

test $# -gt 0 && run_tests "$@"

# If there, all is good

echo3 ALL $test_count TESTS SUCCESSFUL

