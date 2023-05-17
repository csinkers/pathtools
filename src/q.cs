using System;
using System.IO;
using System.Diagnostics;

public static class Program
{
    public static void Main()
    {
        string input;
        string tempFile;
        using (var stdin = Console.OpenStandardInput())
        using (var tr = new StreamReader(stdin))
        {
            input = tr.ReadToEnd();
            if (string.IsNullOrWhiteSpace(input))
            {
                Console.WriteLine("No results");
                return;
            }
            tempFile = Path.GetTempFileName();
            File.WriteAllText(tempFile, input);
        }

        var process = new Process
        {
            StartInfo = new ProcessStartInfo("gvim", $"+cb \"{tempFile}\"")
            {
                UseShellExecute = false
            }
        };

        process.Start();
    }
}
