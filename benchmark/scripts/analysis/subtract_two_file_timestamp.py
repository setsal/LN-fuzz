import os
import time
import click


@click.command()
@click.argument('files', nargs=-1, required=True)
def main(files):

    modify_time0 = int(os.path.getmtime(files[0]))
    modify_time1 = int(os.path.getmtime(files[1]))

    print(modify_time0)
    print(modify_time1)
    print(modify_time0-modify_time1)


if __name__ == '__main__':
    main()
