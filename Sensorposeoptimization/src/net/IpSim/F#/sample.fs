// Copyright (c) Microsoft Corporation 2005-2008.
// This sample code is provided "as is" without warranty of any kind. 
// We disclaim all warranties, either express or implied, including the 
// warranties of merchantability and fitness for a particular purpose. 


module Sample.Support

open System
open Microsoft.FSharp.Reflection

type sample = 
    { Run: (unit -> unit);
      Category: string;
      Name: string;
      Title: string;
      Description: string;
      File: string;
      Code: string;
      StartIndex: int }

[<System.AttributeUsage(AttributeTargets.Method, AllowMultiple = false)>]
type TitleAttribute(title:string) = 
    inherit Attribute()
    member x.Title = title

[<System.AttributeUsage(AttributeTargets.All, AllowMultiple = false)>]
type SupportAttribute(v:string) = 
    inherit Attribute()
    member x.SampleName = v

[<System.AttributeUsage(AttributeTargets.Method, AllowMultiple = false)>]
type PrefixAttribute(prefix:string) = 
    inherit Attribute()
    member x.Prefix = prefix

[<System.AttributeUsage(AttributeTargets.Method, AllowMultiple = false)>]
type CategoryAttribute(category:string) = 
    inherit Attribute()
    member x.Category = category

[<System.AttributeUsage(AttributeTargets.Method, AllowMultiple = false)>]
type DescriptionAttribute(description:string) = 
    inherit Attribute()
    member x.Description = description


// A dummy type, used to hook our own assembly.  A common .NET reflection idiom
type ThisAssem = { dummy: int }

let getSamples () =
    let assem = (typeof<ThisAssem>).Assembly 
    let appdir = AppDomain.CurrentDomain.BaseDirectory 

    // Search the types this program, which are fact F# modules.
    assem.GetTypes()
    |> Array.filter FSharpType.IsModule
    |> Array.map (fun m -> 
        let typ = m
        let dir = System.IO.Path.Combine(appdir, @"..\..\")
        let file = System.IO.Path.Combine(dir, typ.Name + ".fs") 

        // Collect up the samples each F# module...
        let samples = 
            m.GetMembers()
            // We only want the methods with a TitleAttribute, which should always be static
            |> Array.filter (fun m -> (m.GetCustomAttributes((typeof<TitleAttribute>),false)).Length <> 0) 
            // Prepare an entry for each one...
            |> Array.map (fun m -> 
                 let m = (m :?> System.Reflection.MethodInfo) 
                 let name = m.Name
                 
                 // Crack the related attributes...
                 let category = 
                     let arr = (m.GetCustomAttributes((typeof<CategoryAttribute>),false)) 
                     if arr.Length = 0 then "<no category>" else (arr.[0] :?> CategoryAttribute).Category 
                 let title = 
                     let arr = (m.GetCustomAttributes((typeof<TitleAttribute>),false)) 
                     if arr.Length = 0 then "<no title>" else (arr.[0] :?> TitleAttribute).Title 
                 let desc = 
                     let arr = (m.GetCustomAttributes((typeof<DescriptionAttribute>),false)) 
                     if arr.Length = 0 then "<no description>" else (arr.[0] :?> DescriptionAttribute).Description 
                 let code,blockStart = 
                     try 
                         let allCode = using (new System.IO.StreamReader(file)) (fun sr -> sr.ReadToEnd())
                         let cut x = if x = -1 then allCode.Length else x 
                         let funcStart = allCode.IndexOf("let "+name)
                         let funcStart = min (allCode.LastIndexOf("#",funcStart,30) |> cut) funcStart
                         // printf "name = %s, funcStart = %O, #allCode = %d\n" name funcStart allCode.Length;
                         let codeBlock (blockStart:int) = 
                             let blockEnd = 
                                 min (cut (allCode.IndexOf("[<",blockStart )))
                                     (cut (allCode.IndexOf("(*",blockStart ))) 
                             allCode.Substring(blockStart, blockEnd - blockStart)
                         let supportCode = 
                             let supportAttribute = allCode.LastIndexOf("Support(\"" + name + "\")" ,funcStart) 
                             if supportAttribute = -1 then "" 
                             else codeBlock(allCode.IndexOf("let",supportAttribute)) 
                         let code = codeBlock(funcStart) 
                         supportCode + code,funcStart
                     with e -> e.ToString(),0


                 // Build the sample description.  The code to invoke the sample uses reflection to invoke the
                 // method.
                 { Run = (fun () -> ignore(m.Invoke(null, Array.ofList [  ] )));
                   Category = category;
                   Name=name;
                   Title=title;
                   Description=desc;
                   StartIndex=blockStart;
                   Code= code;
                   File=file }) 

            // Set the samples this module by location the source file
            |> Array.toList
            |> List.sortBy (fun m -> m.StartIndex)
         
        typ.Name,samples)
    |> Array.filter (fun (_,s) -> not(List.isEmpty s))
    |> Seq.sortBy (fun (nm,s) -> nm)
    |> Seq.toList
