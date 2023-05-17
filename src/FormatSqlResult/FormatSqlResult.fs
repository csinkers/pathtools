open System
open System.IO
open System.Text.RegularExpressions

type LineType =
    | Columns of (string * int * int) list
    | DataRow of string

type TextTable =
    {
        columns : string list
        content : string list list
    }

let columnRegex = new Regex(@"^ *( ?([-]+))+\s*$")
let extractColumnNames (lines : string seq) = seq {
    let mutable (last : string) = null
    let mutable i = 0
    
    for line in lines do
        let m = columnRegex.Match line
    
        if (m.Success && last <> null && last.Length >= line.Length) then
            let g = m.Groups.[1]
            let caps = seq { 
                for c in g.Captures do 
                    let colName = last.Substring(c.Index, c.Length).Trim()
                    yield colName, c.Index, c.Length
            }
            yield Columns (caps |> List.ofSeq)
            last <- null
        else 
            if (last <> null) then
                yield DataRow last
            last <- line
        i <- i + 1
    if (last <> null) then
        yield DataRow last
}

type ExtractionResult =
    | Success of string list
    | Failure of string

let extractValues (cols : (string * int * int) list) (line : string) =
    let requiredLength = cols |> Seq.map (fun (_, i, l) -> i + l) |> Seq.fold (fun a b -> if (a > b) then a else b) 0
    if(requiredLength = 0 || requiredLength > line.Length) then
        Failure line
    else
        seq {
        for (colName, index, length) in cols do 
            if (index + length <= line.Length + 1) then
                yield line.Substring(index, length).Trim()
        } |> List.ofSeq |> Success

type CollectResult =
    | Table of TextTable
    | Other of string

let collectDataRows lines =
    seq {
        let mutable (list : string list list) = []
        let mutable cols = []

        let build () = 
            {
                columns = cols |> List.map (fun (x, _, _) -> x)
                content = list |> List.rev
            }

        for line in lines do
            match line with
            | Columns c -> 
                if (cols.Length > 0) then
                    yield (Table (build()))
                list <- []; cols <- c
            | DataRow s -> 
                match extractValues cols s with
                | Success values -> list <- values::list
                | Failure line -> 
                    if (cols.Length > 0) then
                        yield (Table (build()))
                    list <- []; cols <- []
                    yield (Other line)

        if (cols.Length > 0) then
            yield (Table (build()))
    }

let extractTables = extractColumnNames >> collectDataRows

let splitLines (sr : TextReader) = 
    let rec aux () = seq {
        let line = sr.ReadLine()
        if (line <> null) then
            yield line
            yield! aux()
    }
    aux()

let formatTable (t : TextTable) =
    let lengths =
        [
            [t.columns |> List.map (fun x -> x.Length)]
            t.content |> List.map (fun row -> row |> List.map (fun x -> x.Length))
        ] |> List.concat
    let rec transpose =
        function
        | (_::_)::_ as M -> List.map List.head M :: transpose (List.map List.tail M)
        | _ -> []
    
    let colLengths = 
        lengths 
        |> transpose
        |> List.mapi (fun i x -> (i, List.max x))
        |> Map.ofSeq

    [
        [
            t.columns |> List.mapi (fun i x -> x.PadRight(Map.find i colLengths)) |> String.concat " "
            t.columns |> List.mapi (fun i _ -> String.replicate (Map.find i colLengths) "-") |> String.concat " "
        ]
        t.content |> List.map (fun row -> row |> List.mapi (fun i x -> x.PadRight(Map.find i colLengths)) |> String.concat " ")
    ] |> List.concat |> String.concat Environment.NewLine

[<EntryPoint>]
let main argv = 
    let (sr, sw) = 
        match argv with
        | [||] -> Console.In, Console.Out

        | [| filename |] -> 
            let reader = new StreamReader(filename, Text.Encoding.UTF8) :> TextReader
            (reader, Console.Out)

        | [| filename; outputFilename |] -> 
            let file = File.Open(outputFilename, FileMode.Create)
            let reader = new StreamReader(filename, Text.Encoding.UTF8) :> TextReader
            let writer = new StreamWriter(file, Text.Encoding.UTF8) :> TextWriter
            (reader, writer)

        | _ -> failwith "Usage:\nFormatSqlResult.exe [filename] [outputFilename]\nIf no filename is supplied, read from STDIN\n"

    let tables = sr |> splitLines |> extractTables 

    for extractTableResult in tables do
        match extractTableResult with
        | Table table -> 
            sw.WriteLine()
            let formatted = formatTable table
            sw.WriteLine formatted
            sw.WriteLine()
        | Other line -> sw.WriteLine line

    sw.Flush()
    sw.Close()
    0
