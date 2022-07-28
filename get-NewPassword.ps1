function Get-randomCharacters($length, $Characters) { 
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length } 
    $private:ofs = "" 
    return [String]$characters[$random]
}
function Format-String([string]$inputString) {     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString
}
function Get-newPassword {
    $charactersLower = 'abcdefghijklmnopqrstuvwxyz'
    $charactersUpper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $charactersNumber = '1234567890'
    $charactersSymbols = '!@#+'
    $Password = Get-randomCharacters -length 8 -Characters $charactersLower
    $Password += Get-randomCharacters -length 1 -Characters $charactersUpper
    $Password += Get-randomCharacters -length 2 -Characters $charactersNumber
    $Password += Get-randomCharacters -length 1 -Characters $charactersSymbols
    $global:Password = Format-String $Password
}