using System;
using System.Linq;
using System.IO;
using System.Collections.Generic;

namespace CdBin
{
    class Program
    {
        static void Usage()
        {
            Console.Error.WriteLine("usage: CdBin Debug|Release");
            Console.Error.WriteLine("Navigate to the most relevant bin directory beneath the current path for debug or release");
        }

        static IEnumerable<(string Path, DateTime LatestExeTime)> GetEntries(string path)
        {
            foreach (var dir in Directory.GetDirectories(path, "*", SearchOption.TopDirectoryOnly))
            {
                var name = Path.GetFileName(dir);
                if (name.StartsWith(".") || name.Equals("obj", StringComparison.OrdinalIgnoreCase))
                    continue;


                foreach (var entry in GetEntries(dir))
                    yield return entry;
            }

            var exes = Directory.GetFiles(path, "*.exe", SearchOption.TopDirectoryOnly);
            if (exes.Any())
            {
                var time = exes.Max(x => File.GetLastWriteTimeUtc(x));
                yield return (path, time);
            }
        }

        static int Main(string[] args)
        {
            if (args.Length == 0)
            {
                Usage();
                return 1;
            }

            string pattern = string.Empty;
            switch (args[0].ToLower())
            {
                case "debug":   pattern = "*debug*";   break;
                case "release": pattern = "*release*"; break;
                default:
                    Usage();
                    return 1;
            }

            var curDir = Directory.GetCurrentDirectory();
            if (!Directory.Exists("bin"))
                return 1;

            var dirs = Directory.GetDirectories("bin", pattern, SearchOption.AllDirectories);
            var entries = dirs.Select(x => GetEntries(x)).SelectMany(x => x).OrderByDescending(x => x.LatestExeTime);
            foreach (var entry in entries)
            {
                Console.WriteLine(new DirectoryInfo(entry.Path).FullName);
                return 0;
            }

            Console.Error.WriteLine("No best directory found");
            return 1;
        }
    }
}
