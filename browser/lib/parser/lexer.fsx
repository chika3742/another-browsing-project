let jsonParser (tr:TextReader) =
    let rec value stack = seq {
        match (spaces @>> peek) tr with
        | '{' ->
            while isOneOf "{," tr && (spaces @>> peek) tr <> '}' do
                match peek tr with
                | '\'' | '"' ->
                    let name = (jsonString @<< spaces @<< oneOf ":") tr
                    let ch = (spaces @>> peek) tr
                    match ch with
                    | '{' | '[' ->
                        yield name, ch, "", stack
                        yield! value (name::stack)
                        yield name, (if ch = '{' then '}' else ']'), "", stack
                    | _ ->
                        yield name, ':', jsonValue tr, stack
                | ch ->
                    failwith <| sprintf "jsonParser: unknown '%c'" ch
            (spaces @<< oneOf "}") tr
        | '[' ->
            while isOneOf "[," tr && (spaces @>> peek) tr <> ']' do
                let ch = peek tr
                match ch with
                | '{' | '[' ->
                    yield "", ch, "", stack
                    yield! value (""::stack)
                    yield "", (if ch = '{' then '}' else ']'), "", stack
                | _ ->
                    yield "", ':', jsonValue tr, stack
            (spaces @<< oneOf "]") tr
        | ch ->
            failwith <| sprintf "jsonParser: unknown '%c'" ch }
    value []

let test = """
{
  "log": {
    "version": "1.1",
    "creator": {
      "name": "Foo",
      "version": "1.0" },
    "pages": [
      { "id": "page_1", "title": "Test1" },
      { "id": "page_2", "title": "Test2" }
    ],
    "test": [-1.23, null, [1, 2, 3]]
  }
}
"""

try
    use sr = new StringReader(test)
    for (n, t, v, st) in jsonParser sr do
        let v = if v.Length < 20 then v else v.[..19] + ".."
        printfn "%A %A %c %A" (List.rev st) n t v
with e ->
    printf "%A" e
