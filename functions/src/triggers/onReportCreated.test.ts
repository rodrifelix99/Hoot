import { test } from 'node:test';
import assert from 'node:assert';
import { notifyStaffOfReport } from './onReportCreated.js';

test('notifyStaffOfReport creates notifications for staff', async () => {
  const added: any[] = [];
  const fakeDb: any = {
    collection: (name: string) => ({
      doc: (id: string) => ({
        get: async () =>
          id === 'user1'
            ? { data: () => ({ username: 'alice' }) }
            : { data: () => undefined },
        collection: () => ({
          add: async (data: any) => {
            added.push({ id, data });
          },
        }),
      }),
      where: () => ({
        get: async () => ({ docs: [{ id: 'staff1' }, { id: 'staff2' }] }),
      }),
    }),
  };

  await notifyStaffOfReport(fakeDb, 'r1', { userId: 'user1' });

  assert.equal(added.length, 2);
  assert.ok(
    added.every(
      (a) => a.id.startsWith('staff') && a.data.reportId === 'r1' && a.data.type === 6
    )
  );
});
