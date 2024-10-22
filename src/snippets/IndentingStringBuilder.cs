internal class IndentingStringBuilder
{
    readonly StringBuilder _sb = new StringBuilder();
    readonly int _tabSize;

    string _indentString = "";
    int _indent;
    bool _doIndent;

    public IndentingStringBuilder(int tabSize)
    {
        _tabSize = tabSize;
    }

    public void PushIndent() { _indent++; }
    public void PopIndent() { if (_indent > 0) _indent--; }
    public override string ToString() { return _sb.ToString(); }

    public void AppendLine(string value)
    {
        Append(value);
        Append(Environment.NewLine);
    }

    public void Append(string value)
    {
        for (int index = 0; index < value.Length; index++)
        {
            var c = value[index];
            switch (c)
            {
                case '\r':
                    if ((index + 1) < value.Length && value[index + 1] == '\n')
                        index++;

                    AppendNewLine();
                    break;

                case '\n':
                    AppendNewLine();
                    break;

                default:
                    Indent();
                    _sb.Append(c);
                    break;
            }
        }
    }

    void Indent()
    {
        if (!_doIndent)
            return;

        _doIndent = false;

        if (_indent > 0)
        {
            int length = _indent * _tabSize;
            if (_indentString.Length != length)
                _indentString = new string(' ', length);

            _sb.Append(_indentString);
        }
    }

    void AppendNewLine()
    {
        _sb.AppendLine();
        _doIndent = true;
    }
}
