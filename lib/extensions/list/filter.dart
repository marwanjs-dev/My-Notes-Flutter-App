extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(
          bool Function(T)
              where) => // we need a list that needs to be filtered by a function
      map((items) => items.where(where).toList());
}
