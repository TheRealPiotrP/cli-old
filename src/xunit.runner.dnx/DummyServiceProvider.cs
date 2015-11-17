using System;

namespace Xunit.Runner.Dnx
{
    public class DummyServiceProvider : IServiceProvider
    {
        public object GetService(Type serviceType)
        {
            return null;
        }
    }
}