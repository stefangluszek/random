class Connection
{
    Stdio.File fd;
    Stdio.Buffer ibuffer = Stdio.Buffer();
    Stdio.Buffer obuffer = Stdio.Buffer();

    void create(Stdio.File fd)
    {
        this_program::fd = fd;
        fd->set_nonblocking(read_cb, write_cb, close_cb);
    }

    void send(string data)
    {
        obuffer->add(data);
        write_cb();
    }

    void read_cb(mixed id, string data)
    {
        array a;
        ibuffer->add(data);
        while (a = ibuffer->sscanf("%s\n"))
        {
            werror("got %s\n", a[0]);
            send(a[0] + "\n");
        }
    }

    void write_cb()
    {
        int wrote = obuffer->output_to(fd);
        obuffer->consume(wrote);
    }

    void close_cb()
    {
        werror("close\n");
    }
}
void got_connection(Stdio.Port p)
{
    Connection c = Connection(p->accept());
}

int main()
{
    Stdio.Port port = Stdio.Port();
    if (!port->bind(7890, got_connection))
        exit(3, "Failed to bind port\n");

    port->set_id(port);
    return -1;
}
