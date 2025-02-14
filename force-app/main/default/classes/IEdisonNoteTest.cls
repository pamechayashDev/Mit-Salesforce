@isTest
private class IEdisonNoteTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonNote note1 = IEdisonNote.getExample();
        IEdisonNote note2 = note1;
        IEdisonNote note3 = new IEdisonNote();
        IEdisonNote note4 = note3;

        System.assert(note1.equals(note2));
        System.assert(note2.equals(note1));
        System.assert(note1.equals(note1));
        System.assert(note3.equals(note4));
        System.assert(note4.equals(note3));
        System.assert(note3.equals(note3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonNote note1 = IEdisonNote.getExample();
        IEdisonNote note2 = IEdisonNote.getExample();
        IEdisonNote note3 = new IEdisonNote();
        IEdisonNote note4 = new IEdisonNote();

        System.assert(note1.equals(note2));
        System.assert(note2.equals(note1));
        System.assert(note3.equals(note4));
        System.assert(note4.equals(note3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonNote note1 = IEdisonNote.getExample();
        IEdisonNote note2 = new IEdisonNote();

        System.assertEquals(false, note1.equals('foo'));
        System.assertEquals(false, note2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonNote note1 = IEdisonNote.getExample();
        IEdisonNote note2 = new IEdisonNote();
        IEdisonNote note3;

        System.assertEquals(false, note1.equals(note3));
        System.assertEquals(false, note2.equals(note3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonNote note1 = IEdisonNote.getExample();
        IEdisonNote note2 = new IEdisonNote();

        System.assertEquals(note1.hashCode(), note1.hashCode());
        System.assertEquals(note2.hashCode(), note2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonNote note1 = IEdisonNote.getExample();
        IEdisonNote note2 = IEdisonNote.getExample();
        IEdisonNote note3 = new IEdisonNote();
        IEdisonNote note4 = new IEdisonNote();

        System.assert(note1.equals(note2));
        System.assert(note3.equals(note4));
        System.assertEquals(note1.hashCode(), note2.hashCode());
        System.assertEquals(note3.hashCode(), note4.hashCode());
    }
}