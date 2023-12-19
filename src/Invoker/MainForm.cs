using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Invoker
{
    public partial class MainForm : Form
    {
        const int WM_COPYDATA = 0x4A;
        public MainForm() => InitializeComponent();
        void btnExit_Click(object sender, EventArgs e) => Environment.Exit(0);
        void notifyIcon1_DoubleClick(object sender, EventArgs e) => Show();

        void MainForm_FormClosing(object sender, FormClosingEventArgs e) { e.Cancel = true; Hide(); }
        void MainForm_Load(object sender, EventArgs e)
        {
            var context = System.Threading.SynchronizationContext.Current;
            if (context == null)
                return;

            Task.Factory.StartNew(async () =>
            {
                await Task.Delay(10);
                context.Post(_ => Hide(), null);
            });
        }

        void contextMenuStrip1_ItemClicked(object sender, ToolStripItemClickedEventArgs e) => Environment.Exit(0);

        [StructLayout(LayoutKind.Sequential)]
        struct COPYDATASTRUCT
        {
            public UIntPtr dwData;
            public int cbData;
            public IntPtr lpData;
        }

        protected override void WndProc(ref Message m)
        {
            if (m.Msg != WM_COPYDATA)
            {
                base.WndProc(ref m);
                return;
            }

            var copyData = (COPYDATASTRUCT)m.GetLParam(typeof(COPYDATASTRUCT));
            string command = null;

            if (copyData.dwData == (UIntPtr)1) // ASCII string
            {
                if (copyData.lpData != IntPtr.Zero)
                    command = Marshal.PtrToStringAnsi(copyData.lpData, copyData.cbData - 1);
            }
            else if (copyData.dwData == (UIntPtr)2) // Unicode string
            {
                if (copyData.lpData != IntPtr.Zero)
                    command = Marshal.PtrToStringUni(copyData.lpData, copyData.cbData / 2 - 1);
            }
            else
                return;

            if (string.IsNullOrWhiteSpace(command))
                return;

            var (filename, arguments) = Split(command);

            try
            {
                txtLog.AppendText(command + Environment.NewLine);
                Process.Start(new ProcessStartInfo(filename, arguments));
            }
            catch (Win32Exception)
            {
                MessageBox.Show($"Could not find {filename} on the path (arguments: {arguments})", "Invoker", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }

            m.Result = (IntPtr)1;
        }

        static (string, string) Split(string s)
        {
            bool quoted = false;
            var sb = new StringBuilder();
            for (int i = 0; i < s.Length; i++)
            {
                var c = s[i];
                if (c == '"')
                {
                    quoted = !quoted;
                    continue;
                }
                if (c == ' ' && !quoted)
                    return (sb.ToString(), s.Substring(i + 1));

                sb.Append(c);
            }

            return (sb.ToString(), null);
        }
    }
}
