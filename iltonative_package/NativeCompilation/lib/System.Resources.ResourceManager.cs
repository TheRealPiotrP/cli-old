using System;

namespace System.Resources
{
  public partial class ResourceManager
  {
    public ResourceManager(string baseName, System.Reflection.Assembly assembly) { }
    public ResourceManager(System.Type resourceSource) { }
    public string GetString(string name) { return name; }
    public virtual string GetString(string name, System.Globalization.CultureInfo culture) { return name; }
  }
}
