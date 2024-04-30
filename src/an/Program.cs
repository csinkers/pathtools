using System.Reflection;

namespace AssemblyNameUtil;

public static class Program
{
    public static int Main(string[] args)
    {
        if (args.Length != 1 || !File.Exists(args[0]))
        {
            Console.WriteLine("an - 'AssemblyNameUtil', this utility emits the .NET assembly name of the given file.");
            Console.WriteLine("Usage: an.exe <dll or exe path>");
            return 1;
        }

        try 
        {
            var name = AssemblyName.GetAssemblyName(args[0]);
            Console.WriteLine(name.FullName);
        }
        catch (BadImageFormatException)
        {
            Console.WriteLine("File does not contain a .NET Assembly");
            return 1;
        }

        return 0;
    }
}

