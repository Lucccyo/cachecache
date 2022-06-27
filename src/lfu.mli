module Make (K : sig
  type t

  val equal : t -> t -> bool
  (*@ pure*)

  val hash : t -> int
end) : sig
  type key = K.t

  type 'a t
  
  (*@ ephemeral
      model cap : int
      mutable model assoc : key -> 'a option
      mutable model frequency : key -> int
      invariant cap > 0
      invariant forall k. assoc k <> None <-> frequency k > 0 *)

  val v : int -> 'a t
  (* t = v c
     checks c > 0
     ensures t.cap = c
     ensures forall k. t.assoc k = None *)

  val stats : 'a t -> Stats.t
  val is_empty : 'a t -> bool
  (*@ b = is_empty t
      pure
      ensures b <-> forall k. t.assoc k = None *)

  val capacity : 'a t -> int
  (*@ c = capacity t
      pure
      ensures c = t.cap *)

  val size : 'a t -> int
  (*@ s = size t
      pure 
      ensures s <= t.cap *)

  val clear : 'a t -> unit
  (*@ clear t
      modifies t 
      ensures forall k. t.assoc k = None *)

  val find : 'a t -> key -> 'a
  (*@ v = find t k
      ensures t.assoc k = Some v -> t.frequency k = t.frequency (old k) + 1
      raises Not_found -> t.assoc k = None *)

  val find_opt : 'a t -> key -> 'a option
  (*@ o = find_opt t k
      pure
      ensures o = t.assoc k
      ensures t.assoc k <> None -> t.frequency k = t.frequency (old k) + 1 *)

  val mem : 'a t -> key -> bool
  (*@ b = mem t k
      pure
      ensures b <-> t.assoc k <> None && t.frequency k = t.frequency (old k) + 1 *)

  val replace : 'a t -> key -> 'a -> unit
  (*@ replace t k v
      modifies t
      ensures t.assoc k = Some v
      ensures t.assoc (old k) <> None -> t.frequency k = t.frequency (old k) + 1
      ensures t.assoc (old k) = None ->
        forall k', v'. t.assoc (old k') = Some v' -> t.assoc k' = Some v' && t.frequency k = 1 *)

  val remove : 'a t -> key -> unit
  (*@ remove t k
      modifies t
      ensures t.assoc k = None *)
end
