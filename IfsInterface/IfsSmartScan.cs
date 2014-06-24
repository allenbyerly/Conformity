using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace IfsInterface
{
    public class IfsSmartScan
    {
        private List<string> Scans { get; set; }
        private char Token { get; set; }
        private bool Smart { get; set; }

        public IfsSmartScan()
        {
            Scans = new List<string>();
        }

        public void SetScan(string scan, char token)
        {
            Smart = false;
            Token = token;
            Scans.Clear();
            SetSmartScan(scan);
        }

        public void ResetScan()
        {
            Smart = false;
            Token = new char();
            Scans.Clear();
        }

        public void ResetScan(int currentIndex)
        {
            if (currentIndex >= Scans.Count)
            {
                Smart = false;
                Token = new char();
                Scans.Clear();
            }
        }


        public bool IsSmart()
        {
            return Smart;
        }

        public string GetFirst()
        {
            return Scans[0];
        }

        public string GetLast()
        {
            return Scans[Scans.Count - 1];
        }

        public string GetNext(int index)
        {
            return Scans[index + 1];
        }

        public string GetValueByIndex(int index)
        {
            return Scans[index];
        }

        public int GetIndex(string scan)
        {
            return Scans.IndexOf(scan);
        }

        public int GetFirstIndex()
        {
            return 0;
        }

        public int GetLastIndex()
        {
            return Scans.Count - 1;
        }

        public string GetPrevious(int index)
        {
            return Scans[index - 1];
        }

        public string GetScanType()
        {
            return Scans[0];
        }

        private void SetSmartScan(string scan)
        {
            int index;

            index = scan.IndexOf(Token);

            if (index > -1)
            {
                Smart = true;
                Scans.Add(scan.Substring(0, index));
                SetSmartScan(scan.Substring(index + 1));
            }
            else
            {
                Scans.Add(scan.Substring(0));
            }

        }
/*
        public class SmartTag
        {
            [Description("MODEL")]
            [Browsable(true)]
            public string Model { get; set; }

            [Description("SOURCE")]
            [Browsable(false)]
            public string Source { get; set; }

            [Description("CONTROLLER")]
            [Browsable(true)]
            public string Controller { get; set; }

            [Description("TAG")]
            [Browsable(true)]
            public string Tag { get; set; }

            [Description("VALUE")]
            [Browsable(true)]
            public string Value { get; set; }
            
            [Description("POSITION")]
            [Browsable(false)]
            public string Index { get; set; }

            [Description("STATUS")]
            [Browsable(false)]
            public string Status { get; set; }

            [Description("DETAILS")]
            [Browsable(true)]
            public List<string> Details { get; set; }
            
            [Description("ERRORS")]
            [Browsable(false)]
            public List<string> Errors { get; set; }
            

            public SmartTag() {}

            public SmartTag()
            {
                this.Status = -1;

                this.Tag = "";
                this.Value = "";
                this.Index = 0;

                this.Source = "";
                this.Model = "";
                this.Controller = "";

                this.Details = new List<string>();
                this.Errors = new List<string>();
            }

            public SmartTag(string tag)
            {
                this.Status = -1;

                this.Tag = tag;
                this.Value = "";
                this.Index = 0;

                this.Source = this.Tag;
                this.Model = "";
                this.Controller = this.Tag;

                this.Details = new List<string>();
                this.Errors = new List<string>();

                this.Status = 0;
            }

            public SmartTag(string tag, string value)
            {
                this.Status = -1;

                this.Tag = tag;
                this.Value = value;
                this.Index = 0;

                this.Source = this.Tag;
                this.Model = "";
                this.Controller = this.Tag;

                this.Details = new List<string>();
                this.Errors = new List<string>();

                this.Status = 1;
            }

            public SmartTag(int index, string tag, string value)
            {
                this.Status = -1;

                this.Tag = tag;
                this.Value = value;
                this.Index = index;

                this.Source = this.Tag;
                this.Model = "";
                this.Controller = this.Tag;

                this.Details = new List<string>();
                this.Errors = new List<string>();

                this.Status = 1;
            }

        }


        public class PoweerScan
        {
            public SmartTag NextTag {get; set; }
            public SmartTag CurrentTag {get; set; }
            public SmartTag PreviousTag {get; set; }

            public Dictionary<string, SmartTag> ScanInitializer {get; set; }
            public Dictionary<string, Dictionary<string, SmartTag>> SmartStream{get; set; }

            public PowerScan(Dictionary<string,SmartTag> scanner)
            {
                nextTag = new SmartTag(0, "BEGIN", "-1");
                CurrentTag = new SmartTag(0, "",     "0");
                previousTag = new SmartTag(0, "END",   "1");

                scanner = new Dictionary<string,SmartTag>();

                ScanInitializer.Add(NextTag.Tag, NextTag);
                ScanInitializer.Add(Current.Tag, Current);
                ScanInitializer.Add(Previous.Tag, Previous);
            }

            public PowerScan()
            {
                nextTag = new SmartTag(0, "BEGIN", "-1");
                CurrentTag = new SmartTag(0, "",     "0");
                previousTag = new SmartTag(0, "END",   "1");

                ScanInitializer = new Dictionary<string,SmartTag>(3);

                ScanInitializer.Add(NextTag.Tag, NextTag);
                ScanInitializer.Add(Current.Tag, Current);
                ScanInitializer.Add(Previous.Tag, Previous);
            }

            public Dictionary<string,SmartTag> InitializeScanner(Dictionary<string,SmartTag> scanner)
            {
                scanner = new Dictionary<string,SmartTag>(ScanInitializer);
            }

            public String InitializeSmartScan (string   
            public 


        }
    */
    }
}
