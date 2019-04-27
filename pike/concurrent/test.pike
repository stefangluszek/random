Concurrent.Future do_something_1(void|bool err)
{
    werror("do_something_1\n");
    Concurrent.Promise p = Concurrent.Promise();

    if (err)
        call_out(lambda(){ p->failure("Failed to do the 1st thing\n");}, 1);
    else
        call_out(lambda(){ p->success("Done the 1st thing\n");}, 1);

    return p->future();
}

Concurrent.Future do_something_2()
{
    werror("do_something_2\n");
    Concurrent.Promise p = Concurrent.Promise();
    call_out(lambda(){ p->success("Done the 2nd thing\n");}, 1);
    return p->future();
}

int main()
{
    do_something_1()
        ->on_failure(werror)
        ->on_success(werror);

    do_something_1()
        ->then(do_something_2, werror)
        ->then(werror);

    do_something_1(true)
        ->on_failure(werror)
        ->on_success(werror);

    return -1;
}
