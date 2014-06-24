using System;
using System.Collections.Generic;

namespace IfsInterface
{
    public class IfsLov : ScannerFunctions.Lov
    {
        public IfsLov(int height)
            : base(height)
        {
        }

        protected override string translate(string value)
        {
            return value;
        }
    }
}
