using System.IO;
using Microsoft.Extensions.ProjectModel;

namespace Microsoft.Extensions.Testing.Abstractions
{
    public static class ProjectContextExtensions
    {
        public static string AssemblyPath(this ProjectContext projectContext, string buildConfiguration)
        {
            return Path.Combine(
                projectContext.OutputDirectoryPath(buildConfiguration),
                projectContext.ProjectFile.Name + FileNameSuffixes.DynamicLib);
        }
        public static string PdbPath(this ProjectContext projectContext, string buildConfiguration)
        {
            return Path.Combine(
                projectContext.OutputDirectoryPath(buildConfiguration),
                projectContext.ProjectFile.Name + FileNameSuffixes.ProgramDatabase);
        }

        private static string OutputDirectoryPath(this ProjectContext projectContext, string buildConfiguration)
        {
            return Path.Combine(
                projectContext.ProjectDirectory,
                DirectoryNames.Bin,
                buildConfiguration,
                projectContext.TargetFramework.GetShortFolderName(),
                RuntimeIdentifier.Current);
        }
    }
}
