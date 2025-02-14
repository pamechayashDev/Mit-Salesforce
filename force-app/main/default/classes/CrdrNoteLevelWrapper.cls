global class CrdrNoteLevelWrapper implements Comparable  {
    global String noteLevel;
    global List<CrdrNoteWrapper> notes = new List<CrdrNoteWrapper>();

    global CrdrNoteLevelWrapper(String levelName) {
        noteLevel = levelName;
    }
    public Integer compareTo(Object compareTo) {
         if (compareTo == null) return 1; // Move null values to the end
         CrdrNoteLevelWrapper a = this;
         CrdrNoteLevelWrapper b = (CrdrNoteLevelWrapper)compareTo;
         if (a.noteLevel == null) return 1; // Move null values to the end
         if (b.noteLevel == null) return 1; // Move null values to the end
         if (a.noteLevel == 'General') return -1;
         if (b.noteLevel == 'General') return -1;
         return a.noteLevel.compareTo(b.noteLevel);
    }
}