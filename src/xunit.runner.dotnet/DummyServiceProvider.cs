using System;

namespace Xunit.Runner.DotNet
{
    public class DummyServiceProvider : IServiceProvider
    {
        public object GetService(Type serviceType)
        {
            return null;
        }
    }
}