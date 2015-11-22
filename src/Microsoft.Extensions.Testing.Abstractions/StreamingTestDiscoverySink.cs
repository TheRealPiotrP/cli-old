using System;
using System.IO;

namespace Microsoft.Extensions.Testing.Abstractions
{
    public class StreamingTestDiscoverySink : ITestDiscoverySink
    {
        private readonly LineDelimitedJsonStream _stream;

        public StreamingTestDiscoverySink(Stream stream)
        {
            _stream = new LineDelimitedJsonStream(stream);
        }

        public void SendTest(Test test)
        {
            _stream.Send(test);
        }
    }
}