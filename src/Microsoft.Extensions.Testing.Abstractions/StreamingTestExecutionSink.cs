using System.IO;

namespace Microsoft.Extensions.Testing.Abstractions
{
    public class StreamingTestExecutionSink : ITestExecutionSink
    {
        private readonly LineDelimitedJsonStream _stream;

        public StreamingTestExecutionSink(Stream stream)
        {
            _stream = new LineDelimitedJsonStream(stream);
        }

        public void RecordStart(Test test)
        {
        }

        public void RecordResult(TestResult testResult)
        {
            _stream.Send(testResult);
        }
    }
}