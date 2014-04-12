type 'a t = {
  size: int;
  data: 'a IntMap.t;
};;

let empty = { size = 0; data = IntMap.empty };;

let size a = a.size;;

let get a i =
  if i < 0 || i >= size a
  then raise (Invalid_argument "index out of bounds")
  else IntMap.get a.data i;;

let set a i x =
  if i < 0 || i >= size a
  then raise (Invalid_argument "index out of bounds")
  else { a with data = IntMap.add a.data i x }
;;

let add a x =
  { size = a.size + 1;
    data = IntMap.add a.data a.size x }
;;

let update f a i = set a i (f (get a i));;

let fold f a accu = IntMap.fold_inorder f a.data accu;; 
let iter f a = fold (fun () k v -> f k v) a ();;
