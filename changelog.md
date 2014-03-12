## 0.3.2

  *Breaking Changes:*
    - #107: Change default URI pattern to be less greedy.
      /magazine will now not match also /magazine/last_edition.
      query parameters after ? are still a match (ie /magazine?lastest=true)

  *Bug Fixes:*
    - #106: Remove dead, undocumented tag feature


## 0.3.1

  *Enhancements:*
    - #103: Display file URI instead of meaningless schema identifier in messages

  *Bug Fixes:*
    - #102: - Fix rake pacto:generate task


## 0.3.0

  First stable release
