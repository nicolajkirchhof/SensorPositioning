ls *.mat -Recurse | %{cp $_.fullname "$(Split-Path $_ -Parent | Split-Path -Leaf).mat" }
