#!/usr/bin/pike

constant LIMIT = 80;

/*
* This script will print the number of available ferry tickets
* to the island of Mykines.
* example:
* ./mykines.pike 2019-07-01
* 10:20    2
* 16:20    12
*/
int main(int c, array(string) v)
{
    if (c < 2)
        exit(1, "Usage: pike mykines.pike 2019-07-01\n");

    Calendar.Day day;

    mixed e = catch {
        day = Calendar.dwim_day(v[1]);
    };

    if (e)
        exit(2, "Wrong date format: %s\n", v[1]);

    mapping p = ([
        "year": day->year()->year_no(),
    ]);
    string post_data = Standards.JSON.encode(p);
    string url = "http://mykines.fo/php/searchBooking.php";

    string raw = Protocols.HTTP.post_url_data(url, post_data);
    mixed data;

    e = catch {
        data = Standards.JSON.decode(raw);
    };

    if (e)
        exit(12, "Failed to decode JSON\n");

    mapping(string:int) booked = ([ ]);

    foreach (data, mapping booking)
    {
        string d_location = booking["departureLocation"];
        string d_time = booking["departureTime"];
        string d_date = booking["departureDate"];

        if (!d_location || !d_time || !d_date || !sizeof(d_location)
            || !sizeof(d_time) || !sizeof(d_date))
        {
            continue;
        }

        if (has_prefix(d_location, "S") && d_date == v[1])
        {
            booked[d_time] += (int)booking["adults"];
            booked[d_time] += (int)booking["juniorSenior"];
            booked[d_time] += (int)booking["children"];
        }
    }

    werror("Available tickets to Mykines on: %s\n", v[1]);
    foreach (booked; string hour; int n)
    {
        werror("%s    %d\n", hour, LIMIT - n);
    }
    return 0;
}
