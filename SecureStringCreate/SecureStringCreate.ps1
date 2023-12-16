Add-Type -AssemblyName presentationframework, system.windows.forms, system.drawing, windowsformsintegration

$inputXML = @'
<Window x:Class="WpfApp1.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp1"
        mc:Ignorable="d"
        Title="Credential Encryptor" Height="281" Width="349">
    <Grid Width="350" Margin="0,-15,-1,0">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="0*"/>
            <ColumnDefinition Width="0*"/>
            <ColumnDefinition Width="175"/>
            <ColumnDefinition Width="175"/>
            <ColumnDefinition Width="1"/>
        </Grid.ColumnDefinitions>
        <TextBox x:Name="usernameText" HorizontalAlignment="Left" Margin="119,48,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="143" Grid.Column="2" Grid.ColumnSpan="2"/>
        <PasswordBox x:Name="passwordText" Grid.ColumnSpan="4" HorizontalAlignment="Left" Margin="119,90,0,0" VerticalAlignment="Top" Width="143"/>
        <Label x:Name="password" Content="Password" Grid.ColumnSpan="3" HorizontalAlignment="Left" Margin="29,86,0,0" VerticalAlignment="Top"/>
        <Label x:Name="username" Content="Username" Grid.ColumnSpan="4" HorizontalAlignment="Left" Margin="29,44,0,0" VerticalAlignment="Top"/>
        <Label x:Name="output" Content="Output Path" Grid.ColumnSpan="3" HorizontalAlignment="Left" Margin="29,127,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="outputText" HorizontalAlignment="Left" Margin="119,135,0,0" VerticalAlignment="Top" Width="143" IsReadOnly="True" Grid.Column="2" Grid.ColumnSpan="2"/>
        <Button x:Name="exploreButton" Content="Explore" Grid.ColumnSpan="3" HorizontalAlignment="Left" Margin="106,134,0,0" VerticalAlignment="Top" Grid.Column="3"/>
        <Button x:Name="encryptButton" Content="Encrypt" HorizontalAlignment="Center" Margin="0,215,0,0" VerticalAlignment="Top" Grid.Column="2"/>
        <Button x:Name="cancelButton" Content="Cancel" HorizontalAlignment="Center" Margin="0,215,0,0" VerticalAlignment="Top" IsCancel="True" Grid.Column="3"/>
        <TextBox x:Name="status" Grid.ColumnSpan="4" HorizontalAlignment="Left" Margin="66,161,0,0" TextWrapping="Wrap" Text="Script not started..." VerticalAlignment="Top" Width="216" IsReadOnly="True" IsUndoEnabled="False" TextAlignment="Center" IsTabStop="False"/>
        

    </Grid>
</Window>
'@

$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window' -replace 'x:Class="\S+"', ''
[xml]$XAML = $inputXML

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
}
catch {
    Write-Warning $_.Exception
    throw
}

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    }
    catch {
        throw
    }
}

$var_exploreButton.Add_Click(
    {
        $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
        $foldername.rootfolder = "MyComputer"
        $foldername.ShowDialog()
        $var_outputText.Text = $foldername.SelectedPath
    }
)

$var_encryptButton.Add_Click(
    {
        if ( ($var_passwordText.Password -ne "") -and ($var_usernameText.Text -ne "") -and ($var_outputText.Text -ne "") ) {
            ConvertTo-SecureString -String $var_passwordText.Password -AsPlainText -Force | ConvertFrom-SecureString | Out-File "$($var_outputText.text)\secpwd.txt"
            $var_usernameText.Text | Out-File "$($var_outputText.text)\secuser.txt"
            $var_status.Text = "Username and Password exported to `n$($var_outputText.Text) Folder"
            $var_status.Background = "Green"
            $var_status.Foreground = "White"
        }
        else {
            $var_status.Text = "Please ensure all fields are populated."
            $var_status.Background = "Red"
            $var_status.Foreground = "White"
        }
    }
)
$window.ShowDialog()