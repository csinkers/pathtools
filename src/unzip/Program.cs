using System;
using System.IO;
using System.IO.Compression;

namespace Unzip
{
    internal static class Program
    {
        public static int Main(string[] args)
        {
            if (args.Length != 2)
            {
                Console.WriteLine("Usage: unzip <zip path> <dest folder path>");
                return 1;
            }

            var zipPath = args[0];
            var destPath = args[1];

            if (!File.Exists(zipPath))
            {
                Console.WriteLine($"Target zip \"{zipPath}\" not found");
                return 2;
            }

            if (File.Exists(destPath))
            {
                Console.WriteLine($"Destination folder \"{destPath}\" already exists as a file name");
                return 3;
            }

            try
            {
                ExtractZip(zipPath, destPath);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error extracting zip: {ex}");
                return 4;
            }

            return 0;
        }

        static void ExtractZip(string zipPath, string destDir)
        {
            Directory.CreateDirectory(destDir);

            using var stream = File.Open(zipPath, FileMode.Open, FileAccess.Read, FileShare.Read);
            using var zip = new ZipArchive(stream, ZipArchiveMode.Read);

            foreach (var entry in zip.Entries)
            {
                var destPath = Path.Combine(destDir, entry.FullName);
                if (string.IsNullOrEmpty(entry.Name) && entry.Length == 0) // Is it a directory entry?
                {
                    Directory.CreateDirectory(destPath);
                    continue;
                }

                var destSubDir = Path.GetDirectoryName(destPath)!;
                if (!Directory.Exists(destSubDir))
                    Directory.CreateDirectory(destSubDir);

                using var entryStream = entry.Open();
                using var destStream = File.Open(destPath, FileMode.Create);
                entryStream.CopyTo(destStream);
            }
        }
    }
}

