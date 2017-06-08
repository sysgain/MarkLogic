(: 
    1. This script is used to get User Details
    2. This script has to run Security Database in MarkLogic
:)

for $user in /sec:user
    let $username := $user/sec:user-name/text()
    let $description := $user/sec:description/text()
    return 
      <user>
        <username>{$username}</username>
        <description>{$description}</description>
      </user>
