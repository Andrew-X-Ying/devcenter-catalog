param (
    [Parameter()]
    [string]$RepositoryUrl,
    [Parameter()]
    [string]$At,
    [Parameter()]
    [string]$Directory,
    [Parameter()]
    [string]$Branch
)

# ====== Param check

if ([System.String]::IsNullOrWhiteSpace($At))
{
    Write-Error "Empty access token received. Exit 1."
    Exit 1
}

# ====== Create repository folder if it doesnot exist.

try
{
    if (!([System.IO.Directory]::Exists($Directory)))
    {
        New-Item -Path $Directory -ItemType "directory"
        Write-Output "Creating dir ${Directory} done."
    }
}
catch
{
    Write-Error "ExceptionInfo for touching dir ${Directory}: $_"
    Exit 1
}

# ===== Reform repository clone link.

# Sample repo clone link
# https://organization@dev.azure.com/organization/project-name/_git/sample-repo.name
# https://dev.azure.com/organization/project-name/_git/Sample-repo.name
# https://organization.visualstudio.com/project-name/_git/sample-repo.name
# https://organization.visualstudio.com/DefaultCollection/project-name/_git/sample-repo.name

$Pattern1 = '^https://(?<org>[a-zA-Z0-9]+)@dev.azure.com/(?<org_dup>[a-zA-Z0-9]+)/(?<project>[\.\-a-zA-Z0-9]+)/_git/(?<reponame>[\.\-a-zA-Z0-9]+)/?$'
$Pattern2 = '^https://dev.azure.com/(?<org>[a-zA-Z0-9]+)/(?<project>[\.\-a-zA-Z0-9]+)/_git/(?<reponame>[\.\-a-zA-Z0-9]+)/?$'
$Pattern3 = '^https://(?<org>[a-zA-Z0-9]+).visualstudio.com/(?<project>[\.\-a-zA-Z0-9]+)/_git/(?<reponame>[\.\-a-zA-Z0-9]+)/?$'
$Pattern4 = '^https://(?<org>[a-zA-Z0-9]+).visualstudio.com/[Dd]efault[Cc]ollection/(?<project>[\.\-a-zA-Z0-9]+)/_git/(?<reponame>[\.\-a-zA-Z0-9]+)/?$'

$RepositoryUrl = $RepositoryUrl.ToLower()

if ($RepositoryUrl -match $Pattern1)
{
    Write-Output "Match Pattern1"
}
elseif ($RepositoryUrl -match $Pattern2)
{
    Write-Output "Match Pattern2"
}
elseif ($RepositoryUrl -match $Pattern3)
{
    Write-Output "Match Pattern3"
}
elseif ($RepositoryUrl -match $Pattern4)
{
    Write-Output "Match Pattern4"
}
else
{
    Write-Error "RepositoryUrl doesnot match any known pattern. Exit 1."
    Exit 1
}

$ReformPattern = 'https://{org}:{at}@dev.azure.com/{org}/{project}/_git/{reponame}'
$Link = $ReformPattern.Replace('{org}', $Matches.org)
$Link = $Link.Replace('{project}', $Matches.project)
$Link = $Link.Replace('{reponame}', $Matches.reponame)
$Link = $Link.Replace('{at}', $At)

# ===== Git clone

Push-Location $Directory

if ($Branch)
{
    git clone -b $Branch $Link
}
else 
{
    git clone $Link
}

Pop-Location

Write-Output "The repository has been successfully cloned."

Exit 0