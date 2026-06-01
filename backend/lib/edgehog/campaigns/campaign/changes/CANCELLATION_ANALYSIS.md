# Campaign Cancellation Code Analysis

## Current Implementation Overview

### Components

1. **Campaign Resource** (`campaign.ex:187-192`): Defines the `:cancel` action
   - Validation: `ValidateStatus` with `operation: :cancel`
   - Change: `Changes.Cancel`

2. **ValidateStatus** (`validate_status.ex:75-88`): Allows cancellation from
   - `:idle`, `:scheduled`, `:in_progress`, `:pausing`, `:paused`

3. **Changes.Cancel** (`cancel.ex:26-42`): Transition logic
   - Immediate statuses (`:idle`, `:scheduled`, `:paused`): Immediately mark as `:cancelled`
   - Other statuses (`:in_progress`, `:pausing`): Transition to `:cancelling`

4. **Executor** (`lazy_batch.ex`): Handles `:cancelling` state
   - If targets in progress: wait for them to complete
   - When all complete: mark campaign as `:cancelled`

## Issues Identified

### Issue 1: `:pausing` State Not Explicitly Handled in Immediate Statuses

**Severity**: Medium
**Location**: `Changes.Cancel` line 26
**Problem**:

- `:pausing` status is allowed by validation but not included in `@immediate_statuses`
- It transitions to `:cancelling` instead of `:cancelled`
- This is inconsistent - `:pausing` is a transient state like `:idle`/`:scheduled`

**Impact**:

- Campaigns paused mid-execution take longer to cancel
- Inconsistent behavior for user expectations

### Issue 2: Idempotency Not Handled

**Severity**: Low
**Location**: `ValidateStatus` line 75
**Problem**:

- Cannot cancel a campaign already in `:cancelling` state
- User gets error if they retry a cancel operation
- Not idempotent, which is a best practice for critical operations

**Impact**:

- Poor UX if user retries cancellation
- No graceful handling of retry scenarios

### Issue 3: Inconsistent Timestamp Handling

**Severity**: Low
**Location**: `Changes.Cancel` line 30, 35
**Problem**:

- Immediate statuses: `completion_timestamp` set immediately
- Deferred statuses: `completion_timestamp` set by executor later
- Creates two different completion paths

**Impact**:

- Timing inconsistency in metrics/reporting
- More complex for monitoring/analytics

### Issue 4: Outcome Field Not Set for Deferred Cancellation

**Severity**: Medium
**Location**: `Changes.Cancel` line 40
**Problem**:

- When transitioning to `:cancelling`, `:outcome` is not set
- Executor sets it later in `mark_campaign_as_cancelled!`
- Outcome is null during `:cancelling` state

**Impact**:

- GraphQL queries might return null outcome
- API consumers can't know final outcome during `:cancelling`
- Inconsistent with immediate cancellation (where outcome is set)

## Recommendations

1. **Include `:pausing` in immediate statuses** (see Fix #1)
2. **Make cancellation idempotent** (see Fix #2)
3. **Always set completion_timestamp immediately** (see Fix #3)
4. **Always set outcome to :cancelled** (see Fix #4)
5. **Add comprehensive tests** for all state transitions

## Test Coverage Gaps

Currently missing tests for:

- Cancelling a campaign in `:pausing` state
- Cancelling a campaign in `:cancelling` state (idempotency)
- Cancelling a campaign in `:in_progress` state (full flow)
- Verifying timestamp is set correctly
- Verifying outcome is set correctly
