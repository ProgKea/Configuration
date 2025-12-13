#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <limits.h>

static bool
CStrMatch(char *A, char *B)
{
  return strcmp(A, B) == 0;
}

typedef struct
{
  char Name[256];
  bool IsDir;
} entry;

typedef struct
{
  entry *Items;
  int Count;
  int Capacity;
} entries;

static entries
ReadEntireDirectory(const char *DirectoryPath)
{
  entries Result = {0};

  DIR *Directory = opendir(DirectoryPath);
  if(Directory == 0)
  {
    fprintf(stderr, "error: failed to open directory \"%s\": %s\n", DirectoryPath, strerror(errno));
    goto end;
  }

  struct dirent *Entry = 0;
  do
  {
    Entry = readdir(Directory);
    if(Entry != 0 && !CStrMatch(Entry->d_name, ".") && !CStrMatch(Entry->d_name, ".."))
    {
      if(Result.Count <= Result.Capacity)
      {
	if(Result.Capacity == 0)
	{
	  Result.Capacity = 256;
	}
	else
	{
	  Result.Capacity *= 1.5;
	}

	Result.Items = realloc(Result.Items, sizeof(entry)*Result.Capacity);
      }

      entry *Item = Result.Items + Result.Count++;
      memcpy(Item->Name, Entry->d_name, sizeof(Entry->d_name));
      Item->IsDir = Entry->d_type == DT_DIR;
    }
  } while(Entry != 0);

end:
  if(Directory != 0)
  {
    closedir(Directory);
  }

  return Result;
}

int
main(void)
{
  char ExePath[PATH_MAX];
  ssize_t Count = readlink("/proc/self/exe", ExePath, PATH_MAX);
  if(Count == -1)
  {
    fprintf(stderr, "error: failed to read executable path\n");
    return 1;
  }

  for(ssize_t Idx = Count-1; Idx >= 0; --Idx)
  {
    if(ExePath[Idx] == '/')
    {
      Count = Count - (Count - Idx);
      break;
    }
  }

  char *ExeDirectory = malloc(Count+1);
  memcpy(ExeDirectory, ExePath, Count);
  ExeDirectory[Count] = '\0';

  char *HomeDirectory = getenv("HOME");
  if(HomeDirectory == 0)
  {
    fprintf(stderr, "error: failed to get home directory\n");
    return 1;
  }
  entries Entries = ReadEntireDirectory(".");

  for(int Idx = 0; Idx < Entries.Count; ++Idx)
  {
    entry Entry = Entries.Items[Idx];
    char *HomePath = "Home";
    if(Entry.IsDir && CStrMatch(Entry.Name, HomePath))
    {
      entries HomeEntries = ReadEntireDirectory(HomePath);
      for(int Idx = 0; Idx < HomeEntries.Count; ++Idx)
      {
	entry HomeEntry = HomeEntries.Items[Idx];
	char From[PATH_MAX], To[1024];
	memset(From, 0, sizeof(From));
	memset(To, 0, sizeof(To));

	sprintf(From, "%s/%s/%s", ExeDirectory, HomePath, HomeEntry.Name);
	sprintf(To, "%s/%s", HomeDirectory, HomeEntry.Name);

	printf("Symlink %s -> %s\n", From, To);
	if(symlink(From, To) == -1)
	{
	  if(errno == EEXIST)
	  {
	    printf("file already exists\n");
	  }
	  else
	  {
	    printf("error: failed to symlink: %s\n", strerror(errno));
	  }
	}
      }
    }
  }
}
