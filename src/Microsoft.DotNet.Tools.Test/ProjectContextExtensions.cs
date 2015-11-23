using System.IO;
using Microsoft.DotNet.Cli.Utils;
using Microsoft.Extensions.ProjectModel;

namespace Microsoft.DotNet.Tools.Test
{
    public static class ProjectContextExtensions
    {
        public static string OutputPath(this ProjectContext projectContext, string buildConfiguration)
        {
            return Path.Combine(
                projectContext.ProjectDirectory, 
                Constants.BinDirectoryName, 
                buildConfiguration,
                projectContext.TargetFramework.GetShortFolderName(),
                Constants.RuntimeIdentifier,
                projectContext.ProjectFile.Name + Constants.DynamicLibSuffix);
        }
    }
}
