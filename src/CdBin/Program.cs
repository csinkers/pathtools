using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;

namespace CdBin
{
    class Program
    {
        static void Usage()
        {
            Console.Error.WriteLine("usage: CdBin Debug|Release");
            Console.Error.WriteLine("Navigate to the most relevant bin directory beneath the current path for debug or release");
        }

        static KeyValuePair<string, DateTime> LatestExe(KeyValuePair<string, DateTime> current, string path)
        {
            var exes = Directory.GetFiles(path, "*.exe", SearchOption.TopDirectoryOnly);
            if (exes.Any())
            {
                var time = exes.Max(x => File.GetLastWriteTimeUtc(x));
                if (time > current.Value)
                    return new KeyValuePair<string, DateTime>(path, time);
            }

            return current;
        }

        static int Main(string[] args)
        {
            if(args.Length == 0)
            {
                Usage();
                return 1;
            }

            string pattern = string.Empty;
            switch(args[0].ToLower())
            {
                case "debug":
                    pattern = "*debug*";
                    break;
                case "release":
                    pattern = "*release*";
                    break;
                default: 
                    Usage();
                    return 1;
            }
            var curDir = Directory.GetCurrentDirectory();
            if (!Directory.Exists("bin"))
                return 1;

            var dirs = Directory.GetDirectories("bin", pattern, SearchOption.AllDirectories);
            var bestDir = dirs.Aggregate(new KeyValuePair<string, DateTime>(string.Empty, DateTime.MinValue), LatestExe, x => x.Key);
            if (!string.IsNullOrEmpty(bestDir))
            {
                Console.WriteLine(new DirectoryInfo(bestDir).FullName);
                return 0;
            }
            else
            {
                Console.Error.WriteLine("No best directory found");
                return 1;
            }
        }
    }
}
