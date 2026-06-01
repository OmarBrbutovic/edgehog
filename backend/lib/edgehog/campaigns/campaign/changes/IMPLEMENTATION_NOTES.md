# Campaign Cancellation - Implementation Notes

## Key Design Decisions

### 1. Why `:pausing` is Immediate Cancellation

When a campaign is in `:pausing` state:

- The pause operation is still in flight (not completed)
- Cancelling takes logical precedence over pausing
- No point in completing pause transition if we're going to cancel anyway
- User expectation: cancel = stop NOW, not "stop after finishing pause"
- Executor cleanup will handle any orphaned pause state

### 2. Why `:in_progress` is Deferred Cancellation

When a campaign is in `:in_progress` state:

- Operations are actively executing on devices
- Abruptly stopping could leave devices in inconsistent state
- Better UX to gracefully wind down active operations
- Executor coordinates target completion/cleanup
- Minimizes risk of partial/failed operations

### 3. Why `:cancelling` is Idempotent

When a campaign is already `:cancelling`:

- Resubmitting cancel request is a safe no-op
- Critical for API reliability (network timeouts, retries)
- User should not see "error" when retrying safe operation
- Aligns with REST best practices for idempotent operations
- Different from :cancelled (which is terminal) - retrying cancelled should fail

## Testing Strategy

### Test Organization

- **Immediate Scenarios**: Verify immediate state transitions
- **Deferred Scenarios**: Verify `:cancelling` state behavior
- **Error Cases**: Verify rejection of invalid transitions
- **Attribute Validation**: Ensure data consistency
- **Edge Cases**: Empty campaigns, relationship preservation
- **Idempotency**: Retry safety
- **Multi-campaign**: Interaction isolation

### Assertion Strategy

- Status verification (mandatory)
- Outcome verification (mandatory for immediate)
- Timestamp verification (mandatory for immediate, nil for deferred)
- Attribute preservation (campaign name, mechanism, channel)
- ID consistency across retries
- Database state consistency

## Implementation Patterns Used

### 1. Ash Resource Changes Pattern

```elixir
use Ash.Resource.Change

def change(changeset, _opts, _context) do
  # Get current state
  status = Ash.Changeset.get_attribute(changeset, :status)

  case status do
    # Pattern match on status to determine behavior
    _ when status in @immediate_statuses ->
      # Apply immediate changes
    :cancelling ->
      # No-op for idempotency
      changeset
    :in_progress ->
      # Apply deferred behavior
  end
end
```

### 2. Validation Pattern

```elixir
use Ash.Resource.Validation

def validate(changeset, opts, _context) do
  operation = Keyword.fetch!(opts, :operation)
  status = Ash.Changeset.get_attribute(changeset, :status)

  validate_transition(status, operation)
end

defp validate_transition(status, :cancel) do
  case status do
    status when status in @allowed_statuses ->
      :ok
    _other ->
      {:error, Changes.InvalidAttribute.exception(...)}
  end
end
```

### 3. Test Organization Pattern

```elixir
describe "cancel_campaign/1 - immediate cancellation (idle)" do
  test "test name", %{tenant: tenant} do
    # Setup
    # Action
    # Assertion (multiple assertions for comprehensive coverage)
  end
end
```

## Edge Cases Handled

| Case               | Input Status   | Behavior                | Why                                         |
| ------------------ | -------------- | ----------------------- | ------------------------------------------- |
| Cancel idle        | `:idle`        | Immediate ✓             | No active work                              |
| Cancel scheduled   | `:scheduled`   | Immediate ✓             | Future event, cancel before it starts       |
| Cancel paused      | `:paused`      | Immediate ✓             | Already waiting, don't resume to completion |
| Cancel pausing     | `:pausing`     | Immediate ✓             | Transient state, cancel takes precedence    |
| Cancel in-progress | `:in_progress` | Deferred to :cancelling | Active work, wait for targets               |
| Cancel cancelling  | `:cancelling`  | Idempotent ✓            | Already being cancelled, safe no-op         |
| Cancel finished    | `:finished`    | Error ✗                 | Terminal state, immutable                   |
| Cancel cancelled   | `:cancelled`   | Error ✗                 | Terminal state, already done                |

## Potential Future Enhancements

### Timeout Protection

```elixir
# Add to config
campaigns: [
  cancellation_timeout_ms: 300_000  # 5 minutes
]

# In executor
def handle_event(:state_timeout, :cancellation_timeout, :wait_for_campaign_cancelled, data) do
  # Force cancel after timeout
end
```

### Audit Trail

```elixir
# Log who cancelled and when
Ash.Changeset.change_attribute(:cancelled_by, user_id)
Ash.Changeset.change_attribute(:cancelled_at, DateTime.utc_now())
```

### Graceful Shutdown

```elixir
# Stop accepting new operations during cancellation
if campaign.status == :cancelling do
  # Don't start new operations
end
```

## Debugging Campaign Cancellation

### Common Issues

**Q: Campaign stuck in `:cancelling`?**

```elixir
# Check in-progress targets
campaign
|> Ash.load!(:campaign_targets)
|> Map.get(:campaign_targets)
|> Enum.filter(&(&1.status == :in_progress))
# If any, they're holding up completion
```

**Q: Cancellation not taking effect?**

```elixir
# Verify PubSub notification sent
Campaigns.cancel_campaign(campaign)
# Then check executor state
Process.info(executor_pid, :messages)
```

**Q: Timestamp not set?**

```elixir
campaign = Campaigns.cancel_campaign!(campaign)
case campaign.status do
  :cancelled ->
    # Should have timestamp
    IO.inspect(campaign.completion_timestamp)
  :cancelling ->
    # Timestamp will be set by executor later
end
```

## Security Considerations

- ✓ No SQL injection: Uses Ash query building
- ✓ No authorization bypass: Uses Ash authorization
- ✓ No race conditions: Database handles concurrent updates
- ✓ Idempotency safe: No side effects on duplicate calls
- ✓ No data corruption: Atomic status transitions where needed

## Performance Considerations

- **Status Check**: O(1) - single attribute access
- **Idempotency**: No database hit for no-op case
- **State Transition**: Single attribute update, no cascades
- **Executor Notification**: Already async via PubSub
- **No N+1**: Campaign loaded once, targets in executor

## Related Documentation

- `CANCELLATION_ANALYSIS.md` - Detailed analysis
- `CAMPAIGN_CANCELLATION_SUMMARY.md` - Overall summary
- `campaign/campaign.ex:187-192` - Resource definition
- `executors/lazy/lazy_batch.ex:669-685` - Executor handling
