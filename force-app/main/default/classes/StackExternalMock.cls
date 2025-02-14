@isTest
public class StackExternalMock extends ExternalObjectQuery
    {
        final List<Object> items {get; set;}

        public StackExternalMock()
        {
            this.items = new List<Object>();
        }

        protected override List<SObject> passThrough(List<SObject> records)
        {
            return (List<SObject>)this.pop();
        }       

        protected override SObject singlePassThrough(List<SObject> records)
        {
            return (SObject)this.pop();
        }

        public void push(Object itemToPush) {
            this.items.add(itemToPush);
        }

        public Object pop() {
            if (isEmpty()) {
                throw new StackUnderflowException();
            }

            return this.items.remove(size() - 1);
        }

        public Object peek() {
            if (isEmpty()) {
                throw new StackUnderflowException();
            }

            return this.items.get(size() - 1);
        }

        public Integer size() {
            return this.items.size();
        }

        public Boolean isEmpty() {
            return size() == 0;
        }

        public class StackUnderflowException extends Exception {}

    }