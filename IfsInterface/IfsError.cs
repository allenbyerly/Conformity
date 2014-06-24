using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace IfsInterface
{
    public class IfsError
    {
        public string Tag { get; set; }
        public string Caption {get; set;}
        public string Detail { get; set; }

        public IfsError()
        {
            this.Tag = "";
            this.Caption = "";
            this.Detail = "";
        }
    }
}
