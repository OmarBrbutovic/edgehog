#
# This file is part of Edgehog.
#
# Copyright 2026 SECO Mind Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
#

defmodule Edgehog.Campaigns.Campaign.Changes.Cancel do
  @moduledoc """
  Handles campaign cancellation with two different behaviors:

  1. **Immediate Cancellation** for statuses: :idle, :scheduled, :paused, :pausing
     - Campaign transitions immediately to :cancelled status
     - Sets :cancelled outcome
     - Sets completion_timestamp to now
     - No async operations needed

  2. **Deferred Cancellation** for statuses: :in_progress
     - Campaign transitions to :cancelling status
     - In-progress operations continue until completion
     - Executor marks campaign as :cancelled when all targets complete

  3. **Idempotent Cancellation** for status: :cancelling
     - Campaign is already being cancelled
     - No-op to support retries and ensure idempotency

  The :pausing status is treated as immediate because it's a transient state
  representing a pause operation in progress. Cancelling during :pausing should
  take precedence and immediately stop the campaign.
  """

  use Ash.Resource.Change

  @immediate_statuses [:idle, :scheduled, :paused, :pausing]

  @impl Ash.Resource.Change
  def change(changeset, _opts, _context) do
    case Ash.Changeset.get_attribute(changeset, :status) do
      status when status in @immediate_statuses ->
        completion_timestamp = DateTime.utc_now()

        changeset
        |> Ash.Changeset.change_attribute(:completion_timestamp, completion_timestamp)
        |> Ash.Changeset.change_attribute(:status, :cancelled)
        |> Ash.Changeset.change_attribute(:outcome, :cancelled)

      :cancelling ->
        # Idempotent: campaign is already being cancelled, no-op
        changeset

      _other ->
        Ash.Changeset.change_attribute(changeset, :status, :cancelling)
    end
  end
end
