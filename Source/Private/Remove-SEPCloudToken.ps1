function Remove-SEPCloudToken {

    $script:SEPCloudConnection | Add-Member -MemberType NoteProperty -Name AccessToken -Value $null -Force -ErrorAction SilentlyContinue
    $script:configuration | Add-Member -MemberType NoteProperty -Name AccessToken  -Value $null -Force -ErrorAction SilentlyContinue
    if ($script:configuration.CachedTokenPath) {
        try { Remove-Item $script:configuration.CachedTokenPath -Force } catch {}
    }
}
