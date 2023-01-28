/// Kotlinのalso
/// [T]に対する任意の処理をして、最後に[T]を返す
extension AlsoExt<T> on T {
  T also(void Function(T) block) {
    block(this);
    return this;
  }
}

/// Kotlinのlet
/// [T]に対する任意の処理をして、最後にリターンした結果[R]を返す
///
/// valueには最後にリターンしたbar()の型が入る
/// ```
/// final value = obj.let((it) {
///   it.foo();
///   return it.bar();
/// });
/// ```
extension LetExt<T> on T {
  R let<R>(R Function(T) block) {
    return block(this);
  }
}
