namespace System.Diagnostics {
  public static partial class Debug {
    [System.Diagnostics.ConditionalAttribute("DEBUG")]
    public static void Assert(bool condition) { }
    [System.Diagnostics.ConditionalAttribute("DEBUG")]
    public static void Assert(bool condition, string message) { }
  }
}
