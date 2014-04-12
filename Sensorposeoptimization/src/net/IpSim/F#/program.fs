// Copyright (c) Microsoft Corporation 2005-2008.
// This sample code is provided "as is" without warranty of any kind. 
// We disclaim all warranties, either express or implied, including the 
// warranties of merchantability and fitness for a particular purpose. 


open System
open System.Collections.Generic
open System.Windows.Forms
open System.IO
open Sample.Support

/// <summary>
/// The main entry point for the application.
/// </summary>
[<STAThread>]
[<EntryPoint>]
let main(args) = 
    let harnesses = getSamples() 
    match args with 
    | [| _; "/runall" |] -> 
        harnesses 
        |> List.iter (fun (_,samples) -> samples |> List.iter (fun s -> if s.Name <> "ExceptionSample1" then s.Run()))
    | _ -> 
        Application.EnableVisualStyles();
        let form = new Display.SampleForm("F# Micro Samples Explorer", harnesses) 
        ignore(form.ShowDialog())
    0
