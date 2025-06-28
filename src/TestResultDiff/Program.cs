using System.Text.RegularExpressions;
using System.Diagnostics;

namespace TestResultDiff;

internal static class Program
{
    static readonly string[] BeyondComparePaths =
    [
        @"C:\Program Files\Beyond Compare 4\BCompare.exe",
        @"C:\Program Files (x86)\Beyond Compare 4\BCompare.exe"
    ];

    static readonly Regex PartsRegex = new(
        @"Expected:<(?<expected>[\s\S]*)>\. Actual:<(?<actual>[\s\S]*)>\.",
        RegexOptions.Multiline);

    [STAThread]
    public static void Main()
    {
        var clipboardText = Clipboard.GetText();
        var filtered = RemoveFirstLine(clipboardText);

        var parts = ExtractParts(filtered);
        if (parts == null)
            return;

        var (expected, actual) = parts.Value;
        RunBeyondCompare(expected, actual);
    }

    static string RemoveFirstLine(string text)
    {
        var index = text.IndexOf('\n');
        return index < 0 ? text : text[(index + 1)..].TrimStart('\r', '\n');
    }

    static (string Expected, string Actual)? ExtractParts(string input)
    {
        var match = PartsRegex.Match(input);
        if (!match.Success)
            return null;

        var expected = match.Groups["expected"].Value;
        var actual = match.Groups["actual"].Value;
        return (expected, actual);
    }

    static string? FindBeyondComparePath() => BeyondComparePaths.FirstOrDefault(File.Exists);

    static void RunBeyondCompare(string expected, string actual)
    {
        var exePath = FindBeyondComparePath();
        if (exePath == null)
            return;

        // Use unique temp files to avoid conflicts
        var expectedFile = Path.GetTempFileName();
        var actualFile = Path.GetTempFileName();

        File.WriteAllText(expectedFile, expected);
        File.WriteAllText(actualFile, actual);

        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = exePath,
                Arguments = $"\"{expectedFile}\" \"{actualFile}\""
            }
        };

        process.Start();
        process.WaitForExit();
    }
}
